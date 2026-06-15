package demo

class AuthController {

    /**
     * GET /  → show login page (redirect to org list if already logged in)
     */
    def index() {
        if (session.user) {
            redirect controller: 'home', action: 'index'
            return
        }
    }

    /**
     * POST /login → authenticate user
     */
    def login() {
        def username = params.username?.trim()
        def password = params.password

        if (!username || !password) {
            flash.error = 'Username and password are required.'
            redirect action: 'index'
            return
        }

        def user = AppUser.findByUsernameAndPassword(username, password)
        if (user) {
            session.user = [
                id      : user.id,
                username: user.username,
                role    : user.role,
                fullName: user.fullName
            ]
            log.info "User '${user.username}' (${user.role}) logged in."
            redirect controller: 'home', action: 'index'
        } else {
            flash.error = 'Invalid username or password. Please try again.'
            redirect action: 'index'
        }
    }

    /**
     * GET /logout → invalidate session and go back to login
     */
    def logout() {
        def username = session.user?.username
        session.invalidate()
        log.info "User '${username}' logged out."
        redirect action: 'index'
    }
}
