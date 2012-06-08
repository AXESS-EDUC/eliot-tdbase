$("#question\\.titre").blur(function () {
    if ($("#specifobject\\.libelle").val() == "") {
        $("#specifobject\\.libelle").val($("#question\\.titre").val());
    }
    validateForm();
});

$("#specifobject\\.libelle").blur(function () {
    validateForm();
});

function validateForm() {
    try {
        new ValidationService().validate();
    } catch (err) {
        //no validationService registered for this question.
    }
}