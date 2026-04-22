class ApplicationPresenter
  attr_reader :record, :view_context, :current_user

  delegate_missing_to :record

  def initialize(record, view_context, current_user: nil)
    @record = record
    @view_context = view_context
    @current_user = current_user
  end
end
