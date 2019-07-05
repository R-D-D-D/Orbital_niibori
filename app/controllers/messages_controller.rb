class MessagesController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :message_sender, only: :destroy

  def create
    @post = Post.find(params[:post_id])
    @lesson = Lesson.find(params[:lesson_id])
    @message = @post.messages.build(message_params)
    @course = Course.find(params[:course_id])
    if @message.save
      @message.update_attributes(user_id: current_user.id, user_type: current_user.class.name)
      clear_unread(@lesson) if current_user?(@course.tutor)
    end
    back_to_course
  end

  def destroy
    @message.destroy
    back_to_course
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def back_to_course
    redirect_to course_path(@course, lesson_page: @lesson.position, anchor: 'forum')
  end

  # Before filters

  # Checks that the current user is the sender of the message
  def message_sender
    @message = Message.find(params[:id])
    @post = @message.post
    @lesson = @post.lesson
    @course = @lesson.course
    back_to_course unless current_user?(@message.sender)
  end

end
