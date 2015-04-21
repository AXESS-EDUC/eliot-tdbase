package org.lilie.services.eliot.tice.nomenclature

import grails.test.mixin.*
import org.junit.*

@TestFor(MatiereBcn)
class MatiereBcnTests {

  void testCreateMatiere() {
    MatiereBcn matiereBcn = new MatiereBcn(
        libelleCourt: 'MATHS',
        libelleLong: 'MATHEMATIQUES',
        libelleEdition: 'Mathématiques',
        bcnId: 963
    )

    matiereBcn.save()

    assertNotNull(matiereBcn.id)

    matiereBcn = MatiereBcn.findByLibelleCourt('MATHS')

    assertNotNull('Matière MATH non importée', matiereBcn)
    assertEquals('MATHEMATIQUES', matiereBcn.libelleLong)
    assertEquals('Mathématiques', matiereBcn.libelleEdition)
    assertEquals(963, matiereBcn.bcnId)

  }

}
