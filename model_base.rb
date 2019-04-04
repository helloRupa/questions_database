require_relative 'aa_questions'

class ModelBase
  C_TO_TABLE = {
    'QuestionFollow' => 'question_follows',
    'QuestionLike' => 'question_likes',
    'Question' => 'questions',
    'Reply' => 'replies',
    'User' => 'users'
  }.freeze

  def self.find_by_id(id)
    table = C_TO_TABLE[name]

    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table}
      WHERE
        id = ?
    SQL

    return nil if data.empty?

    new(data.first)
  end

  def self.all
    table = C_TO_TABLE[name]

    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table}
    SQL

    return nil if data.empty?

    data.map { |datum| new(datum) }
  end

  def self.where(options)
    table = C_TO_TABLE[name]
    if options.is_a?(Hash)
      values = options.values
      keys = options.keys.map(&:to_s)
      options_str = keys.join(' = ? AND ') + ' = ?'
    else
      options_str, values = parse_string(options)
    end

    data = QuestionsDatabase.instance.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{table}
      WHERE
        #{options_str}
    SQL

    return nil if data.empty?

    data.map { |datum| new(datum) }
  end

  def self.find_by(options)
    where(options)
  end

  def save
    @id.nil? ? insert : update
  end

  def insert
    table, attrs, values = obj_attrs
    attr_str = attrs.map { |attr| attr.to_s[1..-1] }.join(', ')
    q_marks = ('?' * values.length).split('').join(', ')

    QuestionsDatabase.instance.execute(<<-SQL, *values)
      INSERT INTO
        #{table} (#{attr_str})
      VALUES
        (#{q_marks})
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    table, attrs, values = obj_attrs
    attr_val_str = attrs.map { |attr| attr.to_s[1..-1] }.join(' = ?, ') + ' = ?'

    QuestionsDatabase.instance.execute(<<-SQL, *values, @id)
      UPDATE
        #{table}
      SET
        #{attr_val_str}
      WHERE
        id = ?
    SQL
  end

  def obj_attrs
    table = C_TO_TABLE[self.class.name]
    attrs = instance_variables
    values = attrs.map { |attr| instance_variable_get(attr) }
    [table, attrs, values]
  end

  def self.parse_string(str)
    arr = str.split
    options_str = ''
    values = []
    arr.each_with_index do |word, idx|
      if (idx - 2) % 4 == 0
        options_str += '? '
        values << word[1..-2]
        next
      end
      options_str += "#{word} "
    end
    [options_str[0..-2], values]
  end
end
