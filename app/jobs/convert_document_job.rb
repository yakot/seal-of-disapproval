# frozen_string_literal: true

class ConvertDocumentJob
  include Sidekiq::Job

  sidekiq_options queue: :images

  def perform(params = {})
    template = Template.find(params['template_id'])
    attachment = ActiveStorage::Attachment.find(params['attachment_id'])
    extract_fields = params['extract_fields'] || false

    output_dir = Dir.mktmpdir
    ext = File.extname(attachment.filename.to_s)
    base = File.basename(attachment.filename.to_s, ext)

    input_path = File.join(output_dir, "#{base}#{ext}")
    File.binwrite(input_path, attachment.download)

    IO.popen(
      ['soffice', '--headless', '--norestore', '--convert-to', 'pdf',
       '--outdir', output_dir, input_path],
      err: File::NULL
    ) { |io| io.read }

    pdf_path = Dir.glob(File.join(output_dir, '*.pdf')).first

    unless pdf_path && File.exist?(pdf_path)
      Rails.logger.error("ConvertDocumentJob: soffice conversion failed for attachment #{attachment.id}")
      return
    end

    pdf_data = File.binread(pdf_path)
    sha256 = Base64.urlsafe_encode64(Digest::SHA256.digest(pdf_data))

    annotations =
      pdf_data.size < Templates::CreateAttachments::ANNOTATIONS_SIZE_LIMIT ? Templates::BuildAnnotations.call(pdf_data) : []

    new_blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(pdf_data),
      filename: "#{base}.pdf",
      metadata: {
        identified: true,
        analyzed: true,
        pdf: { annotations: }.compact_blank, sha256:
      }.compact_blank,
      content_type: 'application/pdf'
    )

    attachment.update!(blob: new_blob)

    Templates::ProcessDocument.call(attachment, pdf_data, extract_fields:)

    if extract_fields
      fields = attachment.metadata.dig('pdf', 'fields').to_a

      if fields.present?
        fields.each { |f| f['submitter_uuid'] = template.submitters.first['uuid'] }
        template.update!(fields: template.fields + fields)
      end
    end
  ensure
    FileUtils.rm_rf(output_dir) if output_dir
  end
end
