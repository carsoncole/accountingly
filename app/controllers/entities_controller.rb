class EntitiesController < ApplicationController
  before_action :require_authentication
  before_action :set_entity, only: [ :show, :edit, :update, :destroy ]
  before_action :require_administrator, only: [ :edit, :update, :destroy ]

  def index
    @entities = Current.user.entities.active
  end

  def show
    Current.user.update_attribute(:last_use_entity_id, @entity.id)
    @accesses = @entity.accesses
  end

  def new
    @entity = Entity.new
  end

  def edit
  end

  def create
    @entity = Entity.new(entity_params)

    respond_to do |format|
      if @entity.save
        AdministratorAccess.create(user_id: Current.user.id, entity_id: @entity.id)
        format.html { redirect_to @entity, notice: "Entity was successfully created." }
        format.json { render :show, status: :created, location: @entity }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @entity.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @entity.update(entity_params)
        format.html { redirect_to @entity, notice: "Entity was successfully updated." }
        format.json { render :show, status: :ok, location: @entity }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @entity.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @entity.update_attribute(:is_archived, true)
    Current.user.update_attribute(:last_use_entity_id, nil) if Current.user.last_use_entity_id == @entity.id

    respond_to do |format|
      format.html { redirect_to entities_path, notice: "Entity was successfully archived." }
      format.json { head :no_content }
    end
  end

  private

  def set_entity
    @entity = Entity.find(params[:id])
  end

  def require_administrator
    unless Current.user.administrator?(@entity)
      redirect_to entities_path, alert: "You must be an administrator of this entity to perform this action."
    end
  end

  def entity_params
    params.require(:entity).permit(:name)
  end
end
