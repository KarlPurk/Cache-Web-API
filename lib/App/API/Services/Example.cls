Class App.API.Service.Example Extends %RegisteredObject
{

ClassMethod fetchPerson(ByRef output As %ArrayOfDataTypes)
{
	if (+%request.Get("id")=1) 
	{
		set output = ##class(%ArrayOfDataTypes).%New()
  		do output.SetAt(1, "id")
  		do output.SetAt("John", "name")
		quit 
	} 
	
	if (+%request.Get("id")=2) 
	{
		set output = ##class(%ArrayOfDataTypes).%New()
		do output.SetAt(2, "id")
		do output.SetAt("Bob", "name")
	}
}

ClassMethod fetchPeople(ByRef output As %ListOfDataTypes) As %Status
{
  	set john = ##class(%ArrayOfDataTypes).%New()
  	do john.SetAt(1, "id")
  	do john.SetAt("John", "name")
  		
	set bob = ##class(%ArrayOfDataTypes).%New()
	do bob.SetAt(2, "id")
	do bob.SetAt("Bob", "name")
	
	set output = ##class(%ListOfDataTypes).%New()
	do output.Insert(john)
	do output.Insert(bob)
}

}
