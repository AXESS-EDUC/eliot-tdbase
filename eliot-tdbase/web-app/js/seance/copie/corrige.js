$(document).ready(function () {
    $('#menu-item-seances').addClass('actif');

    $('#copieAnnotation').removeAttr('disabled');
    $(".editinplace").editInPlace({
        url:"${g.createLink(controller: 'seance', action: 'updateReponseNote')}",
        success:function (jsonRes) {
            var res = JSON.parse(jsonRes);
            var eltId = "#" + res[0];
            $(eltId).html(res[1]);
            if (res.length > 2) {
                $("#copie_note_finale").html(res[2]);
            }
        }
    });

    new SeanceCopieCommon().deactivateFormElements();
});