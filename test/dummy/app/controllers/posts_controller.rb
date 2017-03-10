class PostsController < ApplicationController
  transcribe only: [:show, :create, :update], additional_data: -> { {data: @data} }

  rescue_from ActiveRecord::RecordNotFound do
    head :not_found
  end

  def create
    @post = Post.create(post_params)
    head :created, location: post_url(@post)
  end

  def show
    @data = 'FOOBAR'
    render json: Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      head :no_content, location: post_url(@post)
    else
      render json: { errors: @post.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    head :ok
  end

private

  def post_params
    params.require(:post).permit(:author, :body)
  end
end
