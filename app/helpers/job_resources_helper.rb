module JobResourcesHelper
  def setup_attachable_resource(thing)
    thing.job_resources.build
  end
  
  def icon_class_for_resource(r)
    s = r.resource_content_type
    prefix = "ss_sprite "
    return prefix + case
    # PDF
    when s == "application/pdf"
      "ss_page_white_acrobat"
    when s == "application/msword"
      "ss_page_white_word"
    when s == "application/mspowerpoint"
      "ss_page_white_powerpoint"
    when s == "application/msexcel" || s == "application/excel" || s == "application/x-excel"
      "ss_page_white_excel"
    # Audio
    when s.match(/audio/)
      "ss_sound"
    # Text
    when s.match(/text/)
      "ss_page_white_text"
    # Image
    when s.match(/image/)
      "ss_image"
    # Archive
    when s == "application/zip" || s == "application/x-compressed"
      "ss_folder_page"
    else 
      "ss_page_white"
    end
  end
  
  def resource_icon_link(r)
    link_to(r.name, r.resource.url, :class => icon_class_for_resource(r)) + " (#{File.extname(r.resource.original_filename)})" 
  end
end
