package org.lilie.services.eliot.tdbase

class SujetController {

  static defaultAction = "recherche"

  def recherche() {
    [
      titrePage:message(code: "sujet.recherche.titre"),
      afficheFormulaire:true
    ]
  }

  def mesSujets() {
    def model = [
      titrePage:message(code: "sujet.messujets.titre"),
      afficheFormulaire:false
    ]
    render(view:"recherche",model: model)
  }


  def nouveau() {
    render(view:"edite", model: [
           titrePage:message(code:"sujet.nouveau.titre")
           ])
  }

  def editeProprietes() {
    render(view:"edite-proprietes")
  }
}
