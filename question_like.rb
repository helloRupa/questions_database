require_relative 'aa_questions'
require_relative 'model_base'

class QuestionLike < ModelBase
  attr_accessor :id, :user_id, :question_id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_likes ON users.id = question_likes.user_id
      WHERE
        question_id = ?
    SQL

    return nil if data.empty?

    data.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT() AS count
      FROM
        question_likes
      WHERE
        question_id = ?
      GROUP BY
        question_id
    SQL

    return 0 if data.empty?

    data.first['count']
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        question_likes.user_id = ?
    SQL

    return nil if data.empty?

    data.map { |datum| Question.new(datum) }
  end

  def self.most_liked_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_likes ON questions.id = question_likes.question_id
      GROUP BY
        question_likes.question_id
      ORDER BY
        COUNT(question_likes.question_id) DESC
      LIMIT
        ?
    SQL

    return nil if data.empty?

    data.map { |datum| Question.new(datum) }
  end
end
