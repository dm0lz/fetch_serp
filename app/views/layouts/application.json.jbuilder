json.response do
  if @error
    json.error @error
  else
    json.data JSON.parse(yield)
  end
end
