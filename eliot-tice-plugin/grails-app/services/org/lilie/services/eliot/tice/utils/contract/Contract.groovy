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
    static def requires(Boolean precondition) {
        if (!precondition) {
            throw new PreConditionException();
        }
    }

    /**
     * Check a postcondition
     * @param postcondition
     */
    static def ensures(Boolean postcondition) {
        if (!postcondition) {
            throw new PostConditionException();
        }
    }

}
