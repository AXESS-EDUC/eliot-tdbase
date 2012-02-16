package org.lilie.services.eliot.tice.qti.model

/**
 * Class to represent an assessmentItem QTI
 * @author franck Silvestre
 */
class AssessmentItem {
  String identifier               // required
  String title                    // required
  boolean adaptive                // required
  boolean timeDependent           // required

  List<Block> blockList = []
  List<ModalFeedback> modalFeedbackList = []


}

/**
 *  Class to represent a modal feedback
 */
class ModalFeedback {
  OutcomeDeclaration outcomeDeclaration
  // ...

}
/**
 *  CClass to represent an OutComeDeclaration
 */
class OutcomeDeclaration {
  String identifier               // required


}

/**
 *  Interface to represent a block in an item body
 */
interface Block {}

/**
 * Class to represent a static block of the item body
 */
class StaticBlock implements Block {
  String content
}

/**
 * Class to represent an interaction block of the item body
 */
class InteractionBlock implements Block {
  ResponseDeclaration responseDeclaration
}

/**
 *  Class to represent a ResponseDeclaration
 */
class ResponseDeclaration {


}

enum AssessmentItemIdentifier {
  choiceMultiple
}