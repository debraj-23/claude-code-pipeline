package demo

class AppUser {

    String username
    String password
    String role      // 'ADMIN' or 'USER'
    String fullName

    static constraints = {
        username unique: true, blank: false
        password blank: false
        role inList: ['ADMIN', 'USER']
        fullName blank: false
    }

    String toString() {
        "$fullName ($role)"
    }
}
