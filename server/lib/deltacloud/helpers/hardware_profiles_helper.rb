module HardwareProfilesHelper

  def format_hardware_property(prop)
    return "&empty;" unless prop
    case prop.kind
      when :range
      "#{prop.first} - #{prop.last} (default: #{prop.default})"
      when :enum
      prop.values.join(', ') + " (default: #{prop.default})"
      else
        prop.value.to_s
    end
  end

end