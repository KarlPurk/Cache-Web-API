/// The App.API class provides a RESTful API layer that returns JSON encoded data
Class App.API Extends %CSP.Page
{

ClassMethod OnPage() As %Status
{
	try
	{
		// Ensure the user has access to the API
		do ..checkAPIAccess()
    	    
    	// Ensure the user has access to the requested service and that the service is valid
    	do ..checkServiceAccess(%request.Get("service"))
	
		// Create an instance of the service that has been requested
		set service = ..serviceFactory(%request.Get("service"))
	
		// Call the requested action of the service instance
		do $method(service, %request.Get("action"), .data)
	
		// If the action produced any data
		if ($data(data))
		{
			// JSON encode the data, and write it to the response body 
			write ##class(App.API.Helper.CacheJSON).Encode(data)
		}
	}
	catch (exception) 		
	{
		// Return an error status/response if an exception was thrown
		write "{""status"": ""error"", ""message"": """_exception.Name_"""}"
	}
	quit $$$OK
}

ClassMethod OnPreHTTP() As %Boolean
{
	// Set the content type to text/json
	do %response.SetHeader("Content-Type","text/json")
	quit 1
}

/**
 * Determines if the user has access to the API
 */
ClassMethod checkAPIAccess() As %Boolean
{
	if (%session.NewSession = 1)
	{
		// TODO: destroy the session
		throw ##class(%Exception.General).%New("API access denied.")
	}
}

/**
 * Determine if the user has access to the requested service 
 * and that the service actually exists
 */
ClassMethod checkServiceAccess(service As %String) As %Boolean
{
	set services = ##class(%ListOfDataTypes).%New()
	do services.Insert("Example")
	if 'services.Find(service) 
	{
		throw ##class(%Exception.General).%New("Invalid service """_service_""" requested.")
	}
	set serviceObj = ..serviceFactory(service)
	if 'serviceObj.hasAccess()
	{
		throw ##class(%Exception.General).%New("You do not have access to the """_service_""" service.")	
	}
}

/**
 * Creates an instance of a service class based on a given string
 */
ClassMethod serviceFactory(service As %String) As %RegisteredObject
{
	quit $case(service,
		"Example":##class(App.API.Service.Example).%New())
}

}
