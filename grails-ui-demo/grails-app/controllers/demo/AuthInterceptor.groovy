package demo

/**
 * Protects all controllers/actions except AuthController.
 * Any request without a valid session is redirected to the login page.
 */
class AuthInterceptor {

    AuthInterceptor() {
        matchAll().excludes(controller: 'auth')
    }

    boolean before() {
        if (!session.user) {
            redirect controller: 'auth', action: 'index'
            return false
        }
        return true
    }

    boolean after() { true }

    void afterView() {}
}
