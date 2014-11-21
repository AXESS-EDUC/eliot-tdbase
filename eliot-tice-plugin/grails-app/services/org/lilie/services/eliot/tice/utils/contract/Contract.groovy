package org.lilie.services.eliot.tice.utils.contract

/**
 * Classe programmation par contrat ultra simplifiée
 * @author Franck Silvestre
 */
class Contract {

    /**
     * Check a precondition
     * @param precondition
     */
    static def requires(Boolean precondition,String message = "") {
        if (!precondition) {
            throw new PreConditionException(message);
        }
    }

    /**
     * Check a postcondition
     * @param postcondition
     */
    static def ensures(Boolean postcondition,String message = "") {
        if (!postcondition) {
            throw new PostConditionException(message);
        }
    }

}
