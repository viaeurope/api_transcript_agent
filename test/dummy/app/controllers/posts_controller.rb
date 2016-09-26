class PostsController < ApplicationController
  transcribe :show, :update

  rescue_from ActiveRecord::RecordNotFound do
    head :not_found
  end

  def create
    render json: { result: :created }, status: :created
  end

  def show
    render json: Post.find(params[:id])
  end

  def update
    render json: { errors: { author: 'must be set' } }, status: :unprocessable_entity
  end
end
