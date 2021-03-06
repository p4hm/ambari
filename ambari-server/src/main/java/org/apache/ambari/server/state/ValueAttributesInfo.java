/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.ambari.server.state;

import org.codehaus.jackson.annotate.JsonProperty;
import org.codehaus.jackson.map.annotate.JsonSerialize;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlElements;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;

@XmlAccessorType(XmlAccessType.FIELD)
@JsonSerialize(include=JsonSerialize.Inclusion.NON_NULL)
public class ValueAttributesInfo {
  private String type;
  private String maximum;
  private String minimum;
  private String unit;

  @XmlElementWrapper(name = "entries")
  @XmlElements(@XmlElement(name = "entry"))
  private Collection<ValueEntryInfo> entries = new ArrayList<ValueEntryInfo>();

  @XmlElement(name = "entries_editable")
  private Boolean entriesEditable;

  @XmlElement(name = "selection-cardinality")
  @JsonProperty("selection_cardinality")
  private String selectionCardinality;

  public ValueAttributesInfo() {

  }

  public String getType() {
    return type;
  }

  public void setType(String type) {
    this.type = type;
  }

  public String getMaximum() {
    return maximum;
  }

  public void setMaximum(String maximum) {
    this.maximum = maximum;
  }

  public String getMinimum() {
    return minimum;
  }

  public void setMinimum(String minimum) {
    this.minimum = minimum;
  }

  public String getUnit() {
    return unit;
  }

  public void setUnit(String unit) {
    this.unit = unit;
  }

  public Collection<ValueEntryInfo> getEntries() {
    return entries;
  }

  public void setEntries(Collection<ValueEntryInfo> entries) {
    this.entries = entries;
  }

  public Boolean getEntriesEditable() {
    return entriesEditable;
  }

  public void setEntriesEditable(Boolean entriesEditable) {
    this.entriesEditable = entriesEditable;
  }

  public String getSelectionCardinality() {
    return selectionCardinality;
  }

  public void setSelectionCardinality(String selectionCardinality) {
    this.selectionCardinality = selectionCardinality;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    ValueAttributesInfo that = (ValueAttributesInfo) o;

    if (entries != null ? !entries.equals(that.entries) : that.entries != null) return false;
    if (entriesEditable != null ? !entriesEditable.equals(that.entriesEditable) : that.entriesEditable != null)
      return false;
    if (maximum != null ? !maximum.equals(that.maximum) : that.maximum != null) return false;
    if (minimum != null ? !minimum.equals(that.minimum) : that.minimum != null) return false;
    if (selectionCardinality != null ? !selectionCardinality.equals(that.selectionCardinality) : that.selectionCardinality != null)
      return false;
    if (type != null ? !type.equals(that.type) : that.type != null) return false;
    if (unit != null ? !unit.equals(that.unit) : that.unit != null) return false;

    return true;
  }

  @Override
  public int hashCode() {
    int result = type != null ? type.hashCode() : 0;
    result = 31 * result + (maximum != null ? maximum.hashCode() : 0);
    result = 31 * result + (minimum != null ? minimum.hashCode() : 0);
    result = 31 * result + (unit != null ? unit.hashCode() : 0);
    result = 31 * result + (entries != null ? entries.hashCode() : 0);
    result = 31 * result + (entriesEditable != null ? entriesEditable.hashCode() : 0);
    result = 31 * result + (selectionCardinality != null ? selectionCardinality.hashCode() : 0);
    return result;
  }

  @Override
  public String toString() {
    return "ValueAttributesInfo{" +
      "entries=" + entries +
      ", type='" + type + '\'' +
      ", maximum='" + maximum + '\'' +
      ", minimum='" + minimum + '\'' +
      ", unit='" + unit + '\'' +
      ", entriesEditable=" + entriesEditable +
      ", selectionCardinality='" + selectionCardinality + '\'' +
      '}';
  }
}

