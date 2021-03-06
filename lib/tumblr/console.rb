
require 'io/console'

module Console

  module_function

  def draw_process_bar(now = 0, total = 1)
    if now < 0 || total <= 0 || (now > total)
      raise "wrong arguments: now => #{now}, total => #{total}"
    end
    rows, cols = IO.console.winsize
    percent = (now * 100.0 / total).round
    header = "#{"% 4d" % percent}% ["
    cols = cols - header.length - 2
    len = (cols / 100.0 * percent).round
    body = if len.zero?
       "#{" " * (cols - len)}] "
    else
      "#{"=" * (len - 1)}#{percent < 100 ? '>' : '='}#{" " * (cols - len)}] "
    end
    print "\r"
    print header + body
    print "\n" if now >= total
  end

end
