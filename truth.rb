require 'sinatra'
require 'sinatra/reloader'

def display_param_error
  erb :error
end

def parameters_valid(true_sym, false_sym, size)
  if true_sym == false_sym && !true_sym.nil? && !false_sym.nil? || size.to_i < 2 && !size.nil?
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
  table = Array.new(table_lines) { Array.new(size.to_i) } # 2^n by n table
  puts 
  # Populate base table lines
  for i in 0..table_lines
    binary_str = i.to_s(2)
    for j in 0..size.to_i
      if binary_str.slice(j) == 0
        table[i][j] = false
      else
        table[i][j] = true
      end
	end
  end
  # Now parse each line per its logical operators
  output = Array.new(table_lines) { Array.new(4) } # 4 logical operators 
  for i in 0..table_lines
    for j in 0..size.to_i
      if j == 0 # AND
        if i == table_lines-1
          output[i][j] = true
        else
          output[i][j] = false
        end

      elsif j == 1 # OR
        if i > 0
          output[i][j] == true
        else
          output[i][j] = false
        end

      elsif j == 2 # NAND
        if output[i][0] == true
          output[i][j] = false
        else
          output[i][j] = true
        end

      elsif j == 3 # NOR
        if output[i][1] == true
          output[i][j] = false
        else
          output[i][j] = true
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

get '/display' do
  # Get the parameters
  true_sym = params['ts']
  false_sym = params['fs']
  size = params['s']
  unless parameters_entered(true_sym, false_sym, size)
    # Default parameters
    true_sym = 'T'
    false_sym = 'F'
    size = 3
  end
  puts true_sym, false_sym, size
  returned = generate_table(true_sym, false_sym, size)
  erb :display, :locals => { true_sym: true_sym, false_sym: false_sym, size: size.to_i, 
      table: returned[0], output: returned[1] }
end