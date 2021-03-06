class Admin::ImagesController < ApplicationController
  before_action :set_image, only: [:edit, :update, :destroy]
  authorize_resource

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)
    @image.user_id = current_user.id

    if @image.save
      @image.journal(:create, current_user, request.remote_ip)
      redirect_to @image, notice: "Image was successfully created"
    else
      flash_first_error(@image, base_only: true)
      render action: "new"
    end
  end

  def update
    if @image.update(image_params)
      @image.journal(:update, current_user, request.remote_ip)
      redirect_to @image, notice: "Image was successfully updated"
    else
      flash_first_error(@image, base_only: true)
      render action: "edit"
    end
  end

  def destroy
    @image.journal(:destroy, current_user, request.remote_ip)
    @image.destroy
    redirect_to images_path, notice: "Image was successfully deleted"
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params[:image].permit(:data, :caption, :credit, :year)
  end
end
