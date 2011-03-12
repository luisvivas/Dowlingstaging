class StatesController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :json

  def index
    @states = Carmen.states(params[:q])
    # Put in chained select JSON format
    @states = @states.collect {|state| {:id => state[1], :text => state[0]}}
    respond_with(@states)
  end
end
