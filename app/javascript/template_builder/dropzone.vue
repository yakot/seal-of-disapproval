<template>
  <div
    class="flex h-[60vh] w-full items-center justify-center"
    @dragover.prevent
    @dragenter="isDragEntering = true"
    @dragleave="isDragEntering = false"
    @drop.prevent="onDropFiles"
  >
    <label
      id="document_dropzone"
      class="w-full max-w-2xl relative rounded-xl border-2 border-dashed transition-all duration-200 cursor-pointer bg-white"
      :class="{
        'opacity-50': isLoading,
        'border-gray-300 hover:border-primary hover:bg-blue-50/30': !isDragEntering,
        'border-primary bg-blue-50/50 scale-[1.02]': isDragEntering
      }"
      :for="inputId"
    >
      <div class="p-12 flex flex-col items-center justify-center text-center">
        <div class="mb-6 rounded-full bg-blue-50 p-4 ring-8 ring-blue-50/50">
          <IconInnerShadowTop
            v-if="isLoading"
            class="animate-spin text-primary"
            :width="48"
            :height="48"
          />
          <component
            :is="icon"
            v-else
            class="stroke-[1.5px] text-primary"
            :width="48"
            :height="48"
          />
        </div>
        
        <div
          v-if="message"
          class="text-xl font-semibold text-gray-900 mb-2"
        >
          {{ message }}
        </div>
        
        <div
          v-if="withDescription"
          class="text-sm text-gray-500 max-w-sm mx-auto"
        >
          <span class="font-medium text-primary hover:text-primary/80 hover:underline">{{ t('click_to_upload') }}</span> 
          {{ t('or_drag_and_drop_files') }}
        </div>
        
        <p class="text-xs text-gray-400 mt-4">
          Supported formats: PDF, PNG, JPG, DOCX
        </p>

        <button
          v-if="withGoogleDrive"
          class="mt-8 flex items-center justify-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary transition-colors pointer-events-auto"
          @click.stop.prevent="$emit('click-google-drive')"
        >
          <IconBrandGoogleDrive class="w-5 h-5 mr-2" />
          <span>{{ t('or_add_from') }} Google Drive</span>
        </button>
      </div>
      <form
        ref="form"
        class="hidden"
      >
        <input
          :id="inputId"
          ref="input"
          type="file"
          name="files[]"
          :accept="acceptFileTypes"
          multiple
          @change="upload"
        >
      </form>
    </label>
  </div>
</template>

<script>
import Upload from './upload'
import { IconCloudUpload, IconFilePlus, IconFileSymlink, IconFiles, IconInnerShadowTop, IconBrandGoogleDrive } from '@tabler/icons-vue'

export default {
  name: 'FileDropzone',
  components: {
    IconFilePlus,
    IconCloudUpload,
    IconInnerShadowTop,
    IconFileSymlink,
    IconFiles,
    IconBrandGoogleDrive
  },
  inject: ['baseFetch', 't'],
  props: {
    templateId: {
      type: [Number, String],
      required: true
    },
    withHoverClass: {
      type: Boolean,
      required: false,
      default: true
    },
    icon: {
      type: String,
      required: false,
      default: 'IconCloudUpload'
    },
    cloneTemplateOnUpload: {
      type: Boolean,
      required: false,
      default: false
    },
    withDescription: {
      type: Boolean,
      required: false,
      default: true
    },
    withGoogleDrive: {
      type: Boolean,
      required: false,
      default: false
    },
    title: {
      type: String,
      required: false,
      default: ''
    },
    acceptFileTypes: {
      type: String,
      required: false,
      default: 'image/*, application/pdf, application/zip, .docx, .doc, .odt, .rtf'
    }
  },
  emits: ['success', 'error', 'loading', 'click-google-drive'],
  data () {
    return {
      isLoading: false,
      isDragEntering: false
    }
  },
  computed: {
    inputId () {
      return 'el' + Math.random().toString(32).split('.')[1]
    },
    uploadUrl () {
      if (this.cloneTemplateOnUpload) {
        return `/templates/${this.templateId}/clone_and_replace`
      } else {
        return `/templates/${this.templateId}/documents`
      }
    },
    message () {
      if (this.isLoading) {
        return this.t('uploading')
      } else {
        return this.title || this.t('add_documents_or_images')
      }
    }
  },
  watch: {
    isLoading (value) {
      this.$emit('loading', value)
    }
  },
  methods: {
    upload: Upload.methods.upload,
    onDropFiles (e) {
      if ([...e.dataTransfer.files].every((f) => f.type.match(/(?:image\/)|(?:application\/pdf)|(?:application\/zip)/) || f.name.match(/\.(?:docx?|xlsx?|odt|rtf)$/i))) {
        this.$refs.input.files = e.dataTransfer.files

        this.upload()
      } else {
        alert(this.t('only_pdf_and_images_are_supported'))
      }
    }
  }
}
</script>
