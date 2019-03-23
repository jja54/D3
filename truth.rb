require 'sinatra'
require 'sinatra/reloader'

def display_param_error
  erb :error
end

def parameters_valid(true_sym, false_sym, size)
  if true_sym == false_sym && !true_sym.nil? && !false_sym.nil? || size.to_i < 2 && !size.nil? || true_sym.length > 1 || false_sym.length > 1
	false
  else
    true
  end
end

def parameters_entered(true_sym, false_sym, size)
  if true_sym.nil? || false_sym.nil? || size.nil?
    false
  else
    true
  end
end

def generate_table(true_sym, false_sym, size)
  table_lines = 2**size.to_i # 2^n values, n bit string
  table = Array.new(table_lines) { Array.new(size.to_i-1) } # 2^n by n table
  # Populate base table lines
  for i in 0..table_lines-1
    binary_str = i.to_s(2).rjust(size.to_i, '0')
    for j in 0..size.to_i-1
      if binary_str.slice(j) == '0'
        table[i][j] = false
      else
        table[i][j] = true
      end
	end
  end
  # Now parse each line per its logical operators
  output = Array.new(table_lines) { Array.new(4) } # 4 logical operators 
  for i in 0..table_lines-1
    for j in 0..4
      if j == 0 # AND
        if i == table_lines-1
          output[i][0] = true
        else
          output[i][0] = false
        end

      elsif j == 1 # OR
        if i > 0
          output[i][1] = true
        else
          output[i][1] = false
        end
      elsif j == 2 # NAND
        if output[i][0] == true
          output[i][2] = false
        else
          output[i][2] = true
        end

      elsif j == 3 # NOR
	    puts output[i][1]
        if output[i][1] == true
          output[i][3] = false
        else
          output[i][3] = true
        end
      end
    end
  end
  return [table, output]
end

# ****************************************
# GET REQUESTS START HERE
# ****************************************

# What to do if we can't find the route
not_found do
  status 404
  erb :error_address, :locals => { status: status }
end

get '/' do
	erb :index
end

post '/display' do
  # Get the parameters
  true_sym = params['ts']
  false_sym = params['fs']
  size = params['s']
  # Default parameters
  if true_sym.nil? || true_sym == ''
    puts 'true is nil'
    true_sym = 'T'
  end
  if false_sym.nil? || false_sym == ''
    false_sym = 'F'
  end
  if size.nil? || size == ''
    size = 3
  end
  if parameters_valid(true_sym, false_sym, size)
    returned = generate_table(true_sym, false_sym, size)
    erb :display, :locals => { true_sym: true_sym, false_sym: false_sym, size: size.to_i, 
      table: returned[0], output: returned[1] }
  else
    erb :error
  end
end