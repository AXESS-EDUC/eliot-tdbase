/*
 * Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
 * This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
 *
 *  Lilie is free software. You can redistribute it and/or modify since
 *  you respect the terms of either (at least one of the both license) :
 *  - under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *  - the CeCILL-C as published by CeCILL-C; either version 1 of the
 *  License, or any later version
 *
 *  There are special exceptions to the terms and conditions of the
 *  licenses as they are applied to this software. View the full text of
 *  the exception in file LICENSE.txt in the directory of this software
 *  distribution.
 *
 *  Lilie is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Licenses for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  and the CeCILL-C along with Lilie. If not, see :
 *  <http://www.gnu.org/licenses/> and
 *  <http://www.cecill.info/licences.fr.html>.
 */

package org.lilie.services.eliot.tice

import org.apache.commons.io.IOUtils
import org.lilie.services.eliot.tice.jackrabbit.core.data.version_2_4_0.DataIdentifier
import org.lilie.services.eliot.tice.jackrabbit.core.data.version_2_4_0.DataRecord
import org.lilie.services.eliot.tice.jackrabbit.core.data.version_2_4_0.DataStore
import org.lilie.services.eliot.tice.jackrabbit.core.data.version_2_4_0.DataStoreException

import java.security.DigestOutputStream
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

/**
 * Database implementation of DataStore
 * @author franck Silvestre
 */
class DBAttachementDataStore implements DataStore {

  /**
   * The digest algorithm used to uniquely identify records.
   */
  private static final String DIGEST = "SHA-1";

  /**
   * Name of the directory used for temporary files.
   * Must be at least 3 characters.
   */
  private static final String TMP = "tmp";

  /**
   * Check if a record for the given identifier exists, and return it if yes.
   * If no record exists, this method returns null.
   *
   * @param identifier data identifier
   * @return the record if found, and null if not
   */
  DataRecord getRecordIfStored(DataIdentifier identifier) throws DataStoreException {
    return DBDataRecord.findByHashId(identifier.toString())
  }

  /**
   * Returns the identified data record. The given identifier should be
   * the identifier of a previously saved data record. Since records are
   * never removed, there should never be cases where the identified record
   * is not found. Abnormal cases like that are treated as errors and
   * handled by throwing an exception.
   *
   * @param identifier data identifier
   * @return identified data record
   * @throws DataStoreException if the data store could not be accessed,
   *                     or if the given identifier is invalid
   */
  DataRecord getRecord(DataIdentifier identifier) throws DataStoreException {
    def res = DBDataRecord.findByHashId(identifier.toString())
    if (!res) {
      throw new DataStoreException("No file with identifier ${identifier.toString()}")
    }
    res
  }

  /**
   * Creates a new data record. The given binary stream is consumed and
   * a binary record containing the consumed stream is created and returned.
   * If the same stream already exists in another record, then that record
   * is returned instead of creating a new one.
   * <p>
   * The given stream is consumed and <strong>not closed</strong> by this
   * method. It is the responsibility of the caller to close the stream.
   * A typical call pattern would be:
   * <pre>
   *     InputStream stream = ...;
   *     try {*         record = store.addRecord(stream);
   *} finally {*         stream.close();
   *}* </pre>
   *
   * @param stream binary stream
   * @return data record that contains the given stream
   * @throws DataStoreException if the data store could not be accessed
   */
  DataRecord addRecord(InputStream input) throws DataStoreException {
    File temporary = null;
    try {
      temporary = File.createTempFile(TMP, null)

      // Copy the stream to the temporary file and calculate the
      // stream length and the message digest of the stream
      long length = 0;
      MessageDigest digest = MessageDigest.getInstance(DIGEST)
      OutputStream output = new DigestOutputStream(new FileOutputStream(temporary), digest)
      try {
        length = IOUtils.copyLarge(input, output)
      } finally {
        output.close()
      }
      DataIdentifier identifier = new DataIdentifier(digest.digest())

      def record = getRecordIfStored(identifier)
      if (!record) {
        DBDataRecord.withTransaction {
          record = new DBDataRecord(hashId: identifier.toString(),
                                    fileContent: temporary.bytes)
          record.save()
        }
      }
      record
    } catch (NoSuchAlgorithmException e) {
      throw new DataStoreException(DIGEST + " not available", e)
    } catch (IOException e) {
      throw new DataStoreException("Could not add record", e)
    } finally {
      if (temporary != null) {
        temporary.delete();
      }
    }

  }

  /**
   * From now on, update the modified date of an object even when accessing it.
   * Usually, the modified date is only updated when creating a new object,
   * or when a new link is added to an existing object. When this setting is enabled,
   * even getLength() will update the modified date.
   *
   * @param before - update the modified date to the current time if it is older than this value
   */
  void updateModifiedDateOnAccess(long before) {}

  /**
   * Delete objects that have a modified date older than the specified date.
   *
   * @param min the minimum time
   * @return the number of data records deleted
   * @throws DataStoreException
   */
  int deleteAllOlderThan(long min) throws DataStoreException {}

  /**
   * Get all identifiers.
   *
   * @return an iterator over all DataIdentifier objects
   * @throws DataStoreException if the list could not be read
   */
  Iterator<DataIdentifier> getAllIdentifiers() throws DataStoreException {

  }

  /**
   * Initialized the data store
   *
   * @param homeDir the home directory of the repository
   * @throws Exception
   */
  void init(String homeDir) throws Exception {}

  /**
   * Get the minimum size of an object that should be stored in this data store.
   * Depending on the overhead and configuration, each store may return a different value.
   *
   * @return the minimum size in bytes
   */
  int getMinRecordLength() {0}

  /**
   * Close the data store
   *
   * @throws DataStoreException if a problem occurred
   */
  void close() throws DataStoreException {}

  /**
   * Clear the in-use list. This is only used for testing to make the the garbage collection
   * think that objects are no longer in use.
   */
  void clearInUse() {}


}


