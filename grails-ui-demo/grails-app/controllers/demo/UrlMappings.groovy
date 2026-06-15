package demo

class UrlMappings {

    static mappings = {
        // Root → login page
        "/"(controller: 'auth', action: 'index')

        // Home (default landing after login — Merchant tab)
        "/home"(controller: 'home', action: 'index')

        // Auth
        "/login"(controller: 'auth', action: 'login', method: 'POST')
        "/logout"(controller: 'auth', action: 'logout')

        // Organisation
        "/organisations"(controller: 'organisation', action: 'index')
        "/organisations/$id/show"(controller: 'organisation', action: 'show')
        "/organisations/$id/edit"(controller: 'organisation', action: 'edit')
        "/organisations/$id/update"(controller: 'organisation', action: 'update', method: 'POST')

        // Catch-all default Grails mapping
        "/$controller/$action?/$id?(.$format)?"{
            constraints {}
        }

        // Error pages
        "500"(view: '/error')
        "404"(view: '/notFound')
    }
}
