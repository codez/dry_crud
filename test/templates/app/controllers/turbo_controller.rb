# Crud controller responding to js as well
class TurboController < CrudController
  def turbo; end

  def update
    super do |format, _success|
      format.turbo_stream
    end
  end
end
