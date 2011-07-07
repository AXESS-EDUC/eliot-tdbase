package org.lilie.services.eliot.tice.scolarite

/**
 * @author bper
 */
public enum IntervalleEnum {
  S1(org.lilie.services.eliot.scolarite.TypeIntervalleEnum.SEMESTRE,1),
  S2(org.lilie.services.eliot.scolarite.TypeIntervalleEnum.SEMESTRE,2),
  T1(org.lilie.services.eliot.scolarite.TypeIntervalleEnum.TRIMESTRE,1),
  T2(org.lilie.services.eliot.scolarite.TypeIntervalleEnum.TRIMESTRE,2),
  T3(org.lilie.services.eliot.scolarite.TypeIntervalleEnum.TRIMESTRE,3),
  ANNEE(org.lilie.services.eliot.scolarite.TypeIntervalleEnum.ANNEE,4)

  private final org.lilie.services.eliot.scolarite.TypeIntervalleEnum typeIntervalle
  private final Integer ordre

  private IntervalleEnum (org.lilie.services.eliot.scolarite.TypeIntervalleEnum typeIntervalle, Integer ordre) {
    this.typeIntervalle = typeIntervalle
    this.ordre = ordre
  }

  public org.lilie.services.eliot.scolarite.TypeIntervalleEnum getTypeIntevalle() {
    return this.typeIntervalle
  }

  public Integer getOrdre() {
    return this.ordre
  }

  /**
  * Interval est Trimestre ou Semestre
  * @return true/false
  * @author msan
  */
  public Boolean isXmestre() {
    return this.typeIntevalle.isXmestre()
  }

  /**
   * Retourne une intervalle "équivalent" :
   * T1 <=> S1, T2 <=> S2, T3 => null, ANNEE => null
   * @param intervalle
   * @return
   * @author bper
   */
  public org.lilie.services.eliot.scolarite.IntervalleEnum getIntevalleEquivalent() {
    switch (this) {
      case (org.lilie.services.eliot.scolarite.IntervalleEnum.T1): return org.lilie.services.eliot.scolarite.IntervalleEnum.S1
      case (org.lilie.services.eliot.scolarite.IntervalleEnum.T2): return org.lilie.services.eliot.scolarite.IntervalleEnum.S2
      case (org.lilie.services.eliot.scolarite.IntervalleEnum.T3): return null
      case (org.lilie.services.eliot.scolarite.IntervalleEnum.S1): return org.lilie.services.eliot.scolarite.IntervalleEnum.T1
      case (org.lilie.services.eliot.scolarite.IntervalleEnum.S2): return org.lilie.services.eliot.scolarite.IntervalleEnum.T2
      case (org.lilie.services.eliot.scolarite.IntervalleEnum.ANNEE): return null
    }
  }

  String getId() {
    return this
  }
  

}