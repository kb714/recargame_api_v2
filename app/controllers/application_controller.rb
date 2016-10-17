class ApplicationController < ActionController::API
  def get_pp_key
    '74h3P47WS7Y2IpzkB39IOJBNmDRKURi1Wz5MDcJw'
  end

  def sendXmlPincenterApi(xml_doc)
    data_return = Net::HTTP.post_form(URI.parse('http://pincenter.recargaweb.cl'), {'XML' => xml_doc})
    Nokogiri.XML data_return.body
  end

  def getCompany name
    case name
      when 'entel'
        '01'
      when 'movistar'
        '02'
      when 'claro'
        '03'
      when 'gtd'
        '08'
      when 'directv'
        '09'
      when 'clarotv'
        '10'
      when 'wom'
        '11'
      when 'vtr'
        '12'
      when 'claro-multimedia'
        '13'
      when 'virgin'
        '14'
      when 'gtel'
        '16'
      when 'falabella'
        '17'
      when 'claro-fijo'
        '18'
      else
        '00'
    end
  end
end
