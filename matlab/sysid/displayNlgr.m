function displayNlgr(states)
for i = 1 : length(states)
  fprintf(' %s', states(i).Name);
  for j = 1 : length(states(i).Value)
    fprintf('\t% 4.2f', states(i).Value(j));
  end
  fprintf('\n');
end
end
