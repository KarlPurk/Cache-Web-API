Cache-Web-API
=============

A Caché ObjectScript Web API.

# Overview

The API is essentially a gateway between the client and server side. The client side application will utilise the API to fetch data and post updates to the server side.

Behind the scenes the API communicates with services classes. The intention is that each application, or perhaps modules within an application, will have at least one service class. This service class is designed for the app/module and will contain specific end points that the client side code can utilise.

The client side application could then utilise these end points to fetch data at appropriate times.

# Service Implementation

As discussed in the overview, it is intended that developers will create their own API services for the projects that they are working on. This section outlines how to create your own service class.

## Create the Service Class

You need to create a new Cache ObjectScript class that extends %RegisteredObject. This class should be created in the following package:

 - App.API.Service

Within this package you will create your service class, for example:

 - App.API.Service.Blog

If you require multiple services for your project, you should group your services together and place them in a new package named after your project such as:

 - App.API.Service.Blog

Within this custom package you will define your services:

 - App.API.Service.Blog.Posts
 - App.API.Service.Blog.Comments
 - App.API.Service.Blog.Users

A basic service class would look like this:

    Class App.API.Service.Blog Extends %RegisteredObject
    {
    
        ClassMethod hasAccess() As %Boolean
        {
            quit 1
        }
        
        ClassMethod fetchLatestPosts() As %ArrayOfDataTypes
        {
            set post1 = ##class(%ArrayOfDataTypes).%New()
            do post1.SetAt(1, "id")
            do post1.SetAt("title", "Welcome to my blog!")
            do post1.SetAt("body", "Welcome to my blog. This is my first post!")
        
            set post2 = ##class(%ArrayOfDataTypes).%New()
            do post2.SetAt(2, "id")
            do post2.SetAt("title", "This is the second post!")
            do post2.SetAt("body", "This is my second post on the blog!")
        
            set output = ##class(%ListOfDataTypes).%New()
            do output.Insert(post1)
            do output.Insert(post2)
        
            quit output
        }
    }

## Register the Service Class(es)

Once you have created your service class(es) you will need to register them with the API. This extra step provides security – we define a “white list” of classes that the API can communicate with, this prevents the API from having direct access to every class in the Cache instance.

Locate and open the `App.API.Helper.ServiceFactory` class.

### Update %onNew() method

The first step is to register your service identifier with the API. This identifier does not need to match your Service class name, but for clarity it probably should do. Basically this identifier is what the client will refer to when using your service – this is the name of the Service in the URL call. For example:

(http://chft-pasdev:57774/csp/ewd/App.API.cls?service=Blog&action=fetchPosts)

The above URL specifies the Blog service – this is the service identifier. This could be anything, such as MyBlog, KarlsBlog, etc. Generally though, it should match the name of your service. This identifier could also be packaged, such as Blog.Posts:

(http://chft-pasdev:57774/csp/ewd/App.API.cls?service=Blog.Posts&action=fetchPosts)

    To register an identifier for a service, add the following code:

    do ..services.Insert("Blog")
    do ..services.Insert("Blog.Posts")

### Update serviceFactory() method

After you have updated the %onNew() method and registered your service identifier you will need to map this identifier to the actual service class. To do this we need to update the create() method and add logic for the creation of your service instance. This is essentially a mapping from the service identifier to the service class:

    "Blog":##class(App.API.Service.Blog).%New(),
    	"Blog.Posts":##class(App.API.Service.Blog.Posts).%New(),

### Add Service actions/end points

Now that you have registered your service with the API you are ready to start creating your service end points.  If you have not done so already you should create your API service now, for example:

    Class App.API.Service.Blog Extends %RegisteredObject
    {
        ClassMethod hasAccess() As %Boolean
        {
	        quit 1
        }
    }

Within this class we can add a new instance method for each service:

    Class App.API.Service.Blog Extends %RegisteredObject
    {

        ClassMethod hasAccess() As %Boolean
        {
            quit 1
        }

        classmethod fetchLatestPosts() As %ListOfDataTypes
        {

        }

    }

In the above example we have added a fetchLatestPosts action to the App.API.Service.Blog service.  However the service is still incomplete and has no logic.  Let’s add a very basic response:

    ClassMethod fetchLatestPosts() As %ArrayOfDataTypes
    {
        set post1 = ##class(%ArrayOfDataTypes).%New()
        do post1.SetAt(1, "id")
        do post1.SetAt("title", "Welcome to my blog!")
        do post1.SetAt("body", "Welcome to my blog. This is my first post!")

        set post2 = ##class(%ArrayOfDataTypes).%New()
        do post2.SetAt(2, "id")
        do post2.SetAt("title", "This is the second post!")
        do post2.SetAt("body", "This is my second post on the blog!")

        set output = ##class(%ListOfDataTypes).%New()
        do output.Insert(post1)
        do output.Insert(post2)

        quit output
    }

### Handling Post & Get Values

You can refer to the Example service for help with handling GET requests, here is a method taken from the Example service showing how to retrieve the value of a GET request parameter.

    ClassMethod fetchPerson() As %ArrayOfDataTypes
    {
    	if (+%request.Get("id")=1)
    	{
    		set output = ##class(%ArrayOfDataTypes).%New()
      		do output.SetAt(1, "id")
      		do output.SetAt("John", "name")
    		quit output
    	}

    	if (+%request.Get("id")=2)
    	{
    		set output = ##class(%ArrayOfDataTypes).%New()
    		do output.SetAt(2, "id")
    		do output.SetAt("Bob", "name")
    		quit output
    	}
    }

In the above code notice how we are using the %request.Get() method to retrieve values from GET.  Similarly, the %request object has a Post method for retrieving POST values.

### Securing your Service

Each Service has a hasAccess() method.  You can use this method to provide fine-grained control over who has access to your service.  For example, within the hasAccess() method you could check one or more of the user’s session variables to ensure that they have access to your service.

    ClassMethod hasAccess() As %Boolean
    {
    	if (%session.Data("accessLevel")'="super-user") {
    		quit 0
    	}
    	quit 1
    }

For example, in the above method we have added a guard statement that ensures that only users with an accessLevel of “super-user” are allowed access to the API service.

### Providing Access to API Services

By default, users are not allowed to access any API services.  API service access is granted on a per-session basis.  To grant your users access to services you must add some code to your index.csp page.  If you don’t have an index.csp page then you probably have an index.html page.  Simply rename the extension from html to csp.  Inside your index.csp page add the following to grant users access to the Blog and Blog.News services:

    <script language="cache" runat="server">
            do ##class(App.API.ServiceSecurity).grantAccess("Blog")
            do ##class(App.API.ServiceSecurity).grantAccess("Blog.News")
    </script>

Now when a user visits your app they will first hit the index.csp page.  This page will then update the users session to enable them access to the specified API services (unless they already had access, in which case the code has no affect).

The API service security class will check the session for access whenever a user attempts to communicate with an API service.

Note that this is different to the hasAccess() method that you define in your Service classes.  The hasAccess() method is intended for finer-grained access, such as limiting the service based on user roles/priviledges.

## The Example Service

In the App.API.Service package there is an example service class called App.API.Service.Example.  This example service has two end points:

 - fetchPeople
 - fetchPerson

### fetchPeople End Point

This end point shows an example of how to return a JSON array from an API service.  You can see the response from this service by pasting the following URL into your browser:

(http://chft-pasdev:57774/csp/ewd/App.API.cls?service=Example&action=fetchPeople)

### fetchPerson End Point
   
This end point shows an example of how to return a single JSON object from an API service.  You can see the response from this service by pasting the following URL into your browser:
    
(http://chft-pasdev:57774/csp/ewd/App.API.cls?service=Example&action=fetchPerson&id=1)
    
You can also change the id parameter to the value 2 to return a different person:
    
(http://chft-pasdev:57774/csp/ewd/App.API.cls?service=Example&action=fetchPerson&id=2)