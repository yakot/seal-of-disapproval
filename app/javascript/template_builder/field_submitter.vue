<template>
  <div
    v-if="mobileView"
    @mouseenter="renderDropdown = true"
    @touchstart="renderDropdown = true"
  >
    <div class="flex space-x-2 items-end">
      <div class="group/contenteditable-container bg-base-100 rounded-md p-2 border border-base-300 w-full flex justify-between items-end roles-dropdown-label-mobile">
        <div class="flex items-center space-x-2">
          <span
            class="w-3 h-3 flex-shrink-0 rounded-full"
            :class="colors[submitters.indexOf(selectedSubmitter) % colors.length]"
          />
          <Contenteditable
            v-model="selectedSubmitter.name"
            class="cursor-text"
            :icon-inline="true"
            :editable="editable"
            :select-on-edit-click="true"
            :icon-width="18"
            @update:model-value="$emit('name-change', selectedSubmitter)"
          />
        </div>
      </div>
      <div class="dropdown dropdown-top dropdown-end roles-dropdown-mobile">
        <label
          tabindex="0"
          class="bg-base-100 cursor-pointer rounded-md p-2 border border-base-300 w-full flex justify-center"
        >
          <IconChevronUp
            width="24"
            height="24"
          />
        </label>
        <ul
          v-if="editable && renderDropdown"
          tabindex="0"
          class="rounded-md min-w-max mb-2"
          :class="menuClasses"
          :style="menuStyle"
          @click="closeDropdown"
        >
          <li
            v-for="(submitter, index) in submitters"
            :key="submitter.uuid"
          >
            <a
              href="#"
              class="flex px-2 group justify-between items-center"
              :class="{ 'active': submitter === selectedSubmitter }"
              @click.prevent="selectSubmitter(submitter)"
            >
              <span class="py-1 flex items-center">
                <span
                  class="rounded-full w-3 h-3 ml-1 mr-3 flex-shrink-0"
                  :class="colors[index % colors.length]"
                />
                <span>
                  {{ submitter.name }}
                </span>
              </span>
              <button
                v-if="submitters.length > 1 && editable"
                class="px-2"
                @click.prevent.stop="remove(submitter)"
              >
                <IconTrashX :width="18" />
              </button>
            </a>
          </li>
          <li v-if="submitters.length < names.length && editable">
            <a
              href="#"
              class="flex px-2"
              @click.prevent="addSubmitter"
            >
              <IconUserPlus
                :width="20"
                :stroke-width="1.6"
              />
              <span class="py-1">
                {{ t('add') }} {{ names[lastPartyIndex] }}
              </span>
            </a>
          </li>
        </ul>
      </div>
    </div>
  </div>
  <div
    v-else
    class="dropdown w-full"
    @mouseenter="renderDropdown = true"
    @touchstart="renderDropdown = true"
  >
    <label
      v-if="compact"
      tabindex="0"
      :title="selectedSubmitter?.name"
      class="cursor-pointer text-base-100 flex h-full items-center justify-center"
    >
      <button
        class="mx-1 w-3 h-3 rounded-full flex-shrink-0"
        :class="colors[submitters.indexOf(selectedSubmitter) % colors.length]"
      />
    </label>
    <label
      v-else
      ref="label"
      tabindex="0"
      class="group cursor-pointer group/contenteditable-container rounded-md p-2.5 border border-gray-300 hover:border-primary w-full flex justify-between items-center bg-white shadow-sm transition-colors"
    >
      <div class="flex items-center space-x-3 overflow-hidden">
        <span
          class="w-3 h-3 rounded-full flex-shrink-0 ring-2 ring-white"
          :class="colors[submitters.indexOf(selectedSubmitter) % colors.length]"
        />
        <Contenteditable
          v-model="selectedSubmitter.name"
          class="cursor-text font-medium text-gray-700 truncate"
          :icon-inline="true"
          :editable="editable"
          :select-on-edit-click="true"
          :icon-width="18"
          @update:model-value="$emit('name-change', selectedSubmitter)"
        />
      </div>
      <span class="flex items-center text-gray-400 group-hover:text-primary transition-colors">
        <component
          :is="editable ? 'IconPlus' : 'IconChevronDown'"
          width="16"
          height="16"
        />
      </span>
    </label>
    <ul
      v-if="(editable || !compact) && renderDropdown"
      tabindex="0"
      :class="menuClasses"
      :style="menuStyle"
      @click="closeDropdown"
    >
      <li
        v-for="(submitter, index) in submitters"
        :key="submitter.uuid"
        class="w-full mb-0.5"
      >
        <a
          href="#"
          class="flex px-2 py-2 group justify-between items-center rounded-md hover:bg-gray-50"
          :class="{ 'bg-blue-50 text-primary': submitter === selectedSubmitter }"
          @click.prevent="selectSubmitter(submitter)"
        >
          <span class="flex items-center overflow-hidden">
            <span
              class="rounded-full w-2.5 h-2.5 ml-1 mr-3 flex-shrink-0"
              :class="colors[index % colors.length]"
            />
            <span class="truncate font-medium text-sm">
              {{ submitter.name }}
            </span>
          </span>
          <div
            v-if="!compact && submitters.length > 1 && editable"
            class="flex items-center"
          >
            <div class="flex-col pr-1 flex invisible group-hover:visible -mt-1 h-0">
              <button
                :title="t('up')"
                class="relative w-4 h-3 flex items-center justify-center hover:text-primary"
                @click.prevent.stop="[move(submitter, -1), $refs.label.focus()] "
              >
                <IconChevronUp width="10" />
              </button>
              <button
                :title="t('down')"
                class="relative w-4 h-3 flex items-center justify-center hover:text-primary"
                @click.prevent.stop="[move(submitter, 1), $refs.label.focus()] "
              >
                <IconChevronDown width="10" />
              </button>
            </div>
            <button
              v-if="!compact && submitters.length > 1 && editable"
              class="invisible group-hover:visible px-1 text-gray-400 hover:text-red-500"
              @click.prevent.stop="remove(submitter)"
            >
              <IconTrashX :width="16" />
            </button>
          </div>
        </a>
      </li>
      <li
        v-if="submitters.length < names.length && editable && allowAddNew"
        class="w-full mt-1 pt-1 border-t border-gray-100"
      >
        <a
          href="#"
          class="flex px-2 py-2 text-primary hover:bg-blue-50 rounded-md font-medium text-sm"
          @click.prevent="addSubmitter"
        >
          <IconUserPlus
            :width="18"
            :stroke-width="2"
            class="mr-2"
          />
          <span>
            {{ t('add') }} {{ names[lastPartyIndex] }}
          </span>
        </a>
      </li>
    </ul>
  </div>
</template>

<script>
import { IconUserPlus, IconTrashX, IconPlus, IconChevronUp, IconChevronDown } from '@tabler/icons-vue'
import Contenteditable from './contenteditable'
import { v4 } from 'uuid'

function getOrdinalSuffix (num) {
  if (num % 10 === 1 && num % 100 !== 11) return 'st'
  if (num % 10 === 2 && num % 100 !== 12) return 'nd'
  if (num % 10 === 3 && num % 100 !== 13) return 'rd'

  return 'th'
}

export default {
  name: 'FieldSubmitter',
  components: {
    IconUserPlus,
    IconChevronDown,
    Contenteditable,
    IconPlus,
    IconTrashX,
    IconChevronUp
  },
  inject: ['t', 'save'],
  props: {
    submitters: {
      type: Array,
      required: true
    },
    editable: {
      type: Boolean,
      required: false,
      default: true
    },
    compact: {
      type: Boolean,
      required: false,
      default: false
    },
    mobileView: {
      type: Boolean,
      required: false,
      default: false
    },
    allowAddNew: {
      type: Boolean,
      required: false,
      default: true
    },
    modelValue: {
      type: String,
      required: true
    },
    menuStyle: {
      type: Object,
      required: false,
      default: () => ({})
    },
    menuClasses: {
      type: String,
      required: false,
      default: 'dropdown-content menu p-2 shadow rounded-box w-full z-10'
    }
  },
  emits: ['update:model-value', 'remove', 'new-submitter', 'name-change'],
  data () {
    return {
      renderDropdown: false
    }
  },
  computed: {
    colors () {
      return [
        'bg-primary',
        'bg-secondary',
        'bg-accent',
        'bg-primary/80',
        'bg-secondary/80',
        'bg-accent/80',
        'bg-primary/60',
        'bg-secondary/60',
        'bg-accent/60',
        'bg-neutral'
      ]
    },
    names () {
      const generatedNames = []

      for (let i = 21; i < 101; i++) {
        const suffix = getOrdinalSuffix(i)

        generatedNames.push(`${i}${suffix} ${this.t('party')}`)
      }

      return [
        this.t('first_party'),
        this.t('second_party'),
        this.t('third_party'),
        this.t('fourth_party'),
        this.t('fifth_party'),
        this.t('sixth_party'),
        this.t('seventh_party'),
        this.t('eighth_party'),
        this.t('ninth_party'),
        this.t('tenth_party'),
        this.t('eleventh_party'),
        this.t('twelfth_party'),
        this.t('thirteenth_party'),
        this.t('fourteenth_party'),
        this.t('fifteenth_party'),
        this.t('sixteenth_party'),
        this.t('seventeenth_party'),
        this.t('eighteenth_party'),
        this.t('nineteenth_party'),
        this.t('twentieth_party'),
        ...generatedNames
      ]
    },
    lastPartyIndex () {
      const index = Math.max(...this.submitters.map((s) => this.names.indexOf(s.name)))

      if (index !== -1) {
        return index + 1
      } else {
        return this.submitters.length
      }
    },
    selectedSubmitter () {
      return this.submitters.find((e) => e.uuid === this.modelValue)
    }
  },
  methods: {
    selectSubmitter (submitter) {
      this.$emit('update:model-value', submitter.uuid)
    },
    remove (submitter) {
      if (window.confirm(this.t('are_you_sure_'))) {
        this.$emit('remove', submitter)
      }
    },
    move (submitter, direction) {
      const currentIndex = this.submitters.indexOf(submitter)

      this.submitters.splice(currentIndex, 1)

      if (currentIndex + direction > this.submitters.length) {
        this.submitters.unshift(submitter)
      } else if (currentIndex + direction < 0) {
        this.submitters.push(submitter)
      } else {
        this.submitters.splice(currentIndex + direction, 0, submitter)
      }

      this.selectSubmitter(submitter)

      this.save()
    },
    addSubmitter () {
      const newSubmitter = {
        name: this.names[this.lastPartyIndex],
        uuid: v4()
      }

      this.submitters.push(newSubmitter)

      this.$emit('update:model-value', newSubmitter.uuid)
      this.$emit('new-submitter', newSubmitter)
    },
    closeDropdown () {
      this.$el.getRootNode().activeElement.blur()
    }
  }
}
</script>
