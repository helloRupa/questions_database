require_relative 'aa_questions'
require_relative 'model_base'

class QuestionFollow < ModelBase
  attr_accessor :id, :question_id, :user_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_follows ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
    SQL

    return nil if data.empty?

    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL

    return nil if data.empty?

    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      GROUP BY
        question_follows.question_id
      ORDER BY
        COUNT(question_follows.question_id) DESC
      LIMIT
        ?
    SQL

    return nil if data.empty?

    data.map { |datum| Question.new(datum) }
  end
end
