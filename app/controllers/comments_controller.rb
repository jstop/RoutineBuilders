class CommentsController < ApplicationController
  # GET /posts/1
  # GET /posts/1.xml
  def show
    @routine = Routine.find(params[:id])
    @comment = Comment.new( :routine => @routine )
  end
  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(params[:comment])
    if signed_in?
      @comment.name = current_user.name
      @comment.user = current_user
    end

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @comment.routine, notice: 'Comment was successfully created.' }
        format.json { render json: @comment, status: :created, location: @comment }
      else
        format.html { redirect_to @comment.routine, notice: "Error creating comment: #{@comment.errors}" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment = Comment.find(params[:id])
    authorize! :delete, @comment
    @routine = @comment.routine
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to @routine }
      format.json { head :no_content }
    end
  end
end
