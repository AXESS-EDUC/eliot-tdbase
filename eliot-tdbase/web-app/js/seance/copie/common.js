function SeanceCopieCommon() {

    /**
     * Deactivation de tous les elements d'un formulaire en dessus d'un element de class item.
     */
    this.deactivateFormElements = function () {
        $('.item').find(':input').attr('disabled', true);
    };

    /**
     * Deactivation de tous les draggables si dans le contexte d'evaluation.
     */
    this.disableDraggablesIfInCorrectionMode = function(draggableSelector) {
        if ($('.correction_copie').length > 0) {
            $(draggableSelector).draggable('destroy');
        }
    };
}