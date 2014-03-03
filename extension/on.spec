
-- Some ways to do the below in one line.
if as == 'string' 
then 
  return table.concat(links,"\n")
else 
  return links
end
	
-- If as were a string, then return table.concat(links, "\n")
-- return on.mtype(as, { string = table.concat(links,"\n"), table = links })

-- If as evaluates to "string", then return table.concat(links, "\n")
-- return on.meval(as, { string = table.concat(links,"\n"), table = links })

-- If as is true then return table.concat(links, "\n")
-- return on.mbool?(as, table.concat(links,"\n"), links )
