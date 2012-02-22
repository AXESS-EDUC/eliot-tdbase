$(document).ready(function () {
    $('#menu-item-seances').addClass('actif');

    $('#copieAnnotation').removeAttr('disabled');

    new SeanceCopieCommon().deactivateFormElements();
});