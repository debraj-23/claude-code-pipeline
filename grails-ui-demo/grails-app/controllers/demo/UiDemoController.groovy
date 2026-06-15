package demo

class UiDemoController {

    def index() {
        // Render the main UI demo page
    }

    def submit() {
        def formData = [
            fullName    : params.fullName,
            email       : params.email,
            password    : params.password,
            description : params.description,
            gender      : params.gender,
            interests   : params.list('interests'),
            rating      : params.rating,
            volume      : params.volume,
            country     : params.country,
            birthDate   : params.birthDate,
            colorPick   : params.colorPick,
            agreeTerms  : params.agreeTerms == 'on'
        ]

        flash.message = "Form submitted successfully!"
        flash.formData = formData
        redirect action: 'result', model: [formData: formData]
    }

    def result() {
        // Displays the submitted form data
    }
}
