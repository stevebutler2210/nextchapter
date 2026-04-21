module ApplicationHelper
  def present(record, presenter_class: nil, **kwargs)
    klass = presenter_class || "#{record.class}Presenter".constantize
    klass.new(record, self, **kwargs)
  end
end
