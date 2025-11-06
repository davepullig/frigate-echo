require 'json'

class Message

  def initialize(json_string)
    @json = JSON.parse(json_string)
  end

  def end_alert?
    @json['type'] == 'end' && 
    @json['before']['severity'] == 'alert'
  end

  def internal_id
    @json['after']['id'].split('-').last
  end

  def camera_name
    @json['after']['camera']
  end

  def start_time
    @json['after']['start_time']
  end

  def end_time
    @json['after']['end_time']
  end

end