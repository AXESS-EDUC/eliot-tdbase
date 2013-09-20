package org.lilie.services.eliot.tdbase.patch

import org.springframework.context.ApplicationContextAware

/**
 * Représente un correctif qui peut être appliqué au lancement de l'application pour effectuer une
 * reprise de données
 *
 * Cette interface hérite de ApplicationContextAware pour permettre à l'implémentation du patch
 * d'exploiter les beans de l'application
 *
 * @author John Tranier
 */
public interface Patch extends ApplicationContextAware{

  void execute()
}