# Controller for the dummy model.
class CrudTestModelsController < CrudController # :nodoc:

  HANDLE_PREFIX = 'handle_'.freeze

  self.search_columns = %i[name whatever remarks]
  self.sort_mappings = { chatty: 'length(remarks)' }
  self.default_sort = 'name'
  self.permitted_attrs = [:name, :email, :password, :whatever, :children,
                          :companion_id, :rating, :income, :birthdate,
                          :gets_up_at, :last_seen, :human, :remarks,
                          { other_ids: [] }]

  before_create :possibly_redirect
  before_create :handle_name
  before_destroy :handle_name

  before_render_new :possibly_redirect
  before_render_new :set_companions

  attr_reader :called_callbacks
  attr_accessor :should_redirect

  # don't use the standard layout as it may require different routes
  # than just the test route for this controller
  layout false

  def index
    entries
    render plain: 'index js' if request.format.js?
  end

  def show
    render html: 'custom html' if entry.name == 'BBBBB'
  end

  def create
    super do |_format, success|
      flash[:notice] = 'model got created' if success
    end
  end

  private

  def list_entries
    entries = super
    if params[:filter]
      entries = entries.where(['rating < ?', 3])
                       .except(:order)
                       .order('children DESC')
    end
    entries
  end

  def build_entry
    entry = super
    entry.companion_id = model_params.delete(:companion_id) if params[model_identifier]
    entry
  end

  # custom callback
  def handle_name
    if entry.name == 'illegal'
      flash[:alert] = 'illegal name'
      throw :abort
    end
  end

  # callback to redirect if @should_redirect is set
  def possibly_redirect
    redirect_to action: 'index' if should_redirect && !performed?
  end

  def set_companions
    @companions = CrudTestModel.where(human: true)
  end

  # create callback methods that record the before/after callbacks
  %i[create update save destroy].each do |a|
    callback = "before_#{a}"
    send(callback.to_sym, :"#{HANDLE_PREFIX}#{callback}")
    callback = "after_#{a}"
    send(callback.to_sym, :"#{HANDLE_PREFIX}#{callback}")
  end

  # create callback methods that record the before_render callbacks
  %i[index show new edit form].each do |a|
    callback = "before_render_#{a}"
    send(callback.to_sym, :"#{HANDLE_PREFIX}#{callback}")
  end

  # handle the called callbacks
  def method_missing(sym, *_args)
    if sym.to_s.starts_with?(HANDLE_PREFIX)
      called_callback(sym.to_s[HANDLE_PREFIX.size..].to_sym)
    else
      super
    end
  end

  def respond_to_missing?(sym, include_private = false)
    sym.to_s.starts_with?(HANDLE_PREFIX) || super
  end

  # records a callback
  def called_callback(callback)
    @called_callbacks ||= []
    @called_callbacks << callback
  end

end
