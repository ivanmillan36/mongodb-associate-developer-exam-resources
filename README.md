# Sección 1: MONGODB OVERVIEW AND THE DOCUMENT MODEL
---

**Identificar el conjunto de tipos de valores que admite BSON de MongoDB**

* [BSON Types \- Database Manual v8.0 \- MongoDB Docs](https://www.mongodb.com/docs/manual/reference/bson-types/)  
* Regla general: BSON admite todos los tipos de datos que admite JSON (cadenas, matrices, booleanos, objetos, nulos)  
  * Además, BSON admite (fecha, fecha-hora, etc.)

* La principal diferencia radica en los tipos de datos numéricos  
  * JSON sólo tiene números (análogo al tipo float) y enteros (64 bits)  
  * BSON ofrece más: int (entero de 32 bits), long (entero de 64 bits) y, por último pero no menos importante, decimal (Decimal128) para cosas de alta precisión.  
      
    

**Documentos Coexistentes**

* El campo _id debe ser único en la misma colección
* Si hay índices únicos creados en otros campos, no se permitirá el documento con el mismo valor para esos campos. 


# Sección 2 : CRUD
---

## **1\. Operaciones de Creación (Create)**

La operación de "Crear" en MongoDB se refiere al proceso de añadir nuevos documentos a una colección. Una característica importante de MongoDB es que, si la colección especificada no existe, se creará automáticamente al realizar la primera operación de inserción. Esta flexibilidad inherente al modelo sin esquema simplifica la interacción inicial con la base de datos.

* **1.1. db.collection.insertOne()**
  Este método se utiliza para insertar un único documento en una colección específica. Se debe proporcionar el documento a insertar como argumento del método. La introducción de este método en la versión 3.2 significó una especialización en las operaciones de inserción, ofreciendo un método dedicado para la inserción de un solo documento. Un ejemplo de sintaxis básica sería:

  ```javascript
   db.collection.insertOne({ name: "Ejemplo" })
  ```
   
  Es importante destacar que esta operación es atómica a nivel de un solo documento, lo que garantiza la integridad de los datos incluso en entornos con múltiples operaciones concurrentes.
* **1.2. db.collection.insertMany()**
  Este método permite insertar múltiples documentos en una colección de una sola vez. Se requiere pasar un array de documentos como argumento. Al igual que insertOne(), este método también se introdujo en la versión 3.2, proporcionando una forma más eficiente de insertar varios documentos en comparación con la ejecución repetida de insertOne(). Un ejemplo de sintaxis básica es:

  ```javascript
  const result = await db.collection('micoleccion').insertMany([
    { name: "Ejemplo 1", age: 25 },
    { name: "Ejemplo 2", age: 30 }
  ]);
  console.log(`${result.insertedCount} documentos fueron insertados`);
  console.log(result.insertedIds);
  ```

  Si bien las inserciones individuales de documentos dentro de insertMany() son atómicas, en versiones anteriores a la 8.0, la operación completa de insertMany() no garantizaba ser completamente transaccional a través de todos los documentos del array por defecto. No obstante, cada inserción individual se considera una operación atómica.
* **1.3. db.createCollection()**
  Aunque no es un método para insertar documentos directamente, db.createCollection() se menciona como una forma de crear una colección vacía. La creación de una colección es un paso previo necesario para poder insertar documentos en ella. Este método permite especificar diversas opciones para la colección, como la definición de índices o reglas de validación, aunque esto va más allá de las operaciones CRUD básicas. Un ejemplo de sintaxis básica sería:
  ```javascript
  db.createCollection("nuevaColeccion")
  ```

## **2\. Operaciones de Lectura (Read)**

La operación de "Leer" se centra en la recuperación de documentos existentes de una colección en MongoDB.

* **2.1. db.collection.find()**
  Este método es fundamental para la recuperación de documentos de una colección basándose en filtros o criterios de consulta específicos. La versatilidad de find() permite realizar consultas complejas, incluyendo la búsqueda en documentos anidados y arrays. Esta capacidad de realizar consultas detalladas es una ventaja significativa del modelo de documentos de MongoDB. Un ejemplo de sintaxis básica es:

  ```javascript
  db.collection.find({ age: { $gt: 25 } })
  ```
  
  Además, existen modificadores de consulta que permiten controlar la cantidad de resultados devueltos, aunque los detalles específicos de estos modificadores no se encuentran en los fragmentos proporcionados.
  * **2.1.1. Modificadores del método find()**
    El método find() acepta varios modificadores que permiten controlar y refinar los resultados devueltos:
    
    - **limit(n)**: Restringe el número de documentos devueltos a un máximo de 'n' documentos. Esto es útil para paginar resultados o cuando solo se necesita un número específico de documentos.
      ```javascript
      db.collection.find().limit(5) // Devuelve máximo 5 documentos
      ```
      
    - **skip(n)**: Omite los primeros 'n' documentos del resultado. Combinado con limit(), permite implementar la paginación de resultados.
      ```javascript
      db.collection.find().skip(10).limit(5) // Omite los primeros 10 documentos y devuelve los 5 siguientes
      ```
      
    - **sort(criterio)**: Ordena los documentos según el criterio especificado. Se define con un objeto donde las claves son los campos por los que ordenar y los valores son 1 (ascendente) o -1 (descendente).
      ```javascript
      db.collection.find().sort({ edad: 1 }) // Ordena por edad de menor a mayor
      db.collection.find().sort({ apellido: 1, nombre: 1 }) // Ordena primero por apellido y luego por nombre
      db.collection.find().sort({ precio: -1 }) // Ordena por precio de mayor a menor
      ```
      
    Estos modificadores se pueden encadenar para crear consultas más complejas, con el siguiente orden de ejecución: primero sort(), luego skip() y finalmente limit().
    ```javascript
    db.collection.find({ categoria: "electrónica" })
      .sort({ precio: -1 })
      .skip(20)
      .limit(10)
    ```
    Este ejemplo devuelve los productos de electrónica del 21 al 30, ordenados por precio de mayor a menor.
  
  - **2.1.2. Proyección de Campos**
    La proyección de campos permite especificar qué campos incluir o excluir en los documentos devueltos por la consulta. Esto es útil para reducir la cantidad de datos transferidos y mejorar el rendimiento.
    ```javascript
    db.collection.find({}, { nombre: 1, edad: 1 }) // Devuelve solo los campos nombre y edad
    db.collection.find({}, { _id: 0, nombre: 1, edad: 1 }) // Excluye el campo _id y devuelve solo nombre y edad
    ```
    Tener en cuenta que no se puede mezclar la inclusión y exclusión de campos en la misma consulta, excepto para el campo _id, que se puede excluir mientras se incluyen otros campos.
    ```javascript
    db.collection.find({}, { _id: 0, nombre: 1, edad: 1 }) // Excluye _id y devuelve nombre y edad
    db.collection.find({}, { nombre: 1, edad: 1 }) // Devuelve nombre y edad, pero incluye _id
    ```
  - **2.1.3. Array query**
    MongoDB permite realizar consultas sobre arrays, lo que facilita la búsqueda de documentos que contienen arrays específicos. Existen varios operadores para trabajar con arrays, como \$elemMatch, \$all y $size.
    ```javascript
    db.collection.find({ hobbies: { $elemMatch: { $eq: "fútbol" } } }) // Busca documentos donde el array hobbies contiene "fútbol"
    db.collection.find({ hobbies: { $all: ["fútbol", "baloncesto"] } }) // Busca documentos donde el array hobbies contiene ambos elementos
    db.collection.find({ hobbies: { $size: 3 } }) // Busca documentos donde el array hobbies tiene exactamente 3 elementos
    ```
    Estos operadores permiten realizar consultas más complejas y específicas en documentos que contienen arrays, lo que es una de las fortalezas del modelo de documentos de MongoDB.
* **2.2. db.collection.findOne()**
  findOne() es un método para obtener un único documento que coincida con los criterios de búsqueda especificados. Si varios documentos cumplen con la consulta, este método devolverá el primero que encuentre, generalmente en el orden natural en que los documentos están almacenados en el disco. findOne() resulta útil en situaciones donde se espera como máximo un documento coincidente o cuando solo se necesita el primer resultado. Un ejemplo de sintaxis básica es:
  
  ```javascript
  db.collection.findOne({ name: "Ejemplo" })
  ```
  
  Su eficiencia radica en que detiene la búsqueda una vez que encuentra el primer documento que satisface la consulta.

## **3\. Operaciones de Actualización (Update)**

La operación de "Actualizar" se refiere a la modificación de documentos ya existentes dentro de una colección de MongoDB. Estas operaciones siempre se dirigen a una única colección y mantienen la atomicidad a nivel de documento individual.

* **3.1. db.collection.updateOne()**
  Este método se utiliza para actualizar un único documento que cumpla con el filtro especificado. Si varios documentos coinciden con el filtro, solo se actualizará el primero que se encuentre. Al igual que los métodos de inserción, updateOne() se introdujo en la versión 3.2.7. Un ejemplo de sintaxis básica es: 
  
  ```javascript
  db.collection.updateOne({ name: "Ejemplo" }, { $set: { age: 30 } })
  ```
  - **Operadores de Actualización en MongoDB**
  Al realizar operaciones de actualización con updateOne() o updateMany(), MongoDB proporciona un conjunto de operadores que permiten modificar los datos de diversas formas. Estos operadores facilitan actualizaciones complejas sin necesidad de recuperar, modificar y reemplazar documentos completos. Los principales operadores son:
    - **Operadores de Campo**
      - **$set:** Establece el valor de un campo específico.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $set: { age: 30, city: "Madrid" } })
        ```
      - **$unset:** Elimina un campo específico de un documento.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $unset: { city: "" } })
        ```
      - **$rename:** Cambia el nombre de un campo existente.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $rename: { city: "location" } })
        ```
      - **$inc:** Incrementa el valor de un campo numérico en una cantidad específica.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $inc: { age: 1 } })
        ```
      - **$mul:** Multiplica el valor de un campo numérico por un factor específico.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $mul: { age: 2 } })
        ```
    - **Operadores de Array**
      - **$push:** Agrega un elemento al final de un array.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $push: { hobbies: "fútbol" } })
        ```
      - **$addToSet:** Agrega un elemento a un array solo si no está ya presente.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $addToSet: { hobbies: "fútbol" } })
        ```
      - **$pop:** Elimina el primer o último elemento de un array.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $pop: { hobbies: 1 } }) // Elimina el último elemento
        ```
      - **$pull:** Elimina todos los elementos que coincidan con un valor específico en un array.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $pull: { hobbies: "fútbol" } })
        ```
      - **$pullAll:** Elimina todos los elementos que coincidan con un array de valores específicos. Similar a **\$pull**, pero permite eliminar múltiples valores a la vez.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $pullAll: { hobbies: ["fútbol", "baloncesto"] } })
        ```
    - **Modificadores para Operadores de Array**
      - **$each:** Aplica una operación a cada elemento de un array.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $set: { "hobbies.$[elem]": "fútbol" } }, { arrayFilters: [{ "elem": "baloncesto" }] })
        ```
      - **$position:** Especifica la posición en la que se debe insertar un nuevo elemento en un array.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $push: { hobbies: { $each: ["fútbol"], $position: 0 } } })
        ```
      - **$slice:** Acorta un array a un número específico de elementos. Este operador se utiliza para limitar la cantidad de elementos en un array.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $slice: { hobbies: -2 } })
        ```
      - **$sort:** Ordena los elementos de un array.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $sort: { hobbies: 1 } })
        ```
      - **$filter:** Filtra los elementos de un array según una condición específica.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $filter: { hobbies: { $gt: 2 } } })
        ```
    - **Operadores Bitwise**
      - **$bit:** Realiza operaciones AND, OR o XOR en valores enteros.
        ```javascript
        db.collection.updateOne({ name: "Juan" }, { $bit: { age: { and: 1 } } })
        ```

    
* **3.2. db.collection.updateMany()**
  Este método permite actualizar todos los documentos que coincidan con el filtro proporcionado. También se introdujo en la versión 3.2.7. Un ejemplo de sintaxis básica es: 
  
  ```javascript
  db.collection.updateMany({ status: "pending" }, { $set: { status: "processed" } })
  ```
  
  Al utilizar updateMany(), es crucial definir el filtro con precisión para evitar modificaciones no deseadas, ya que la operación afectará a todos los documentos que cumplan con los criterios.  
* **3.3. db.collection.replaceOne()**
  Este método reemplaza completamente un único documento que coincida con el filtro especificado con un nuevo documento. Si varios documentos cumplen con el filtro, solo se reemplazará el primero. Su introducción también se produjo en la versión 3.2.7. Un ejemplo de sintaxis básica es:
  
  ```javascript
  db.collection.replaceOne({ _id: ObjectId("someId") }, { newField: "newValue" })
  ```
  
  A diferencia de updateOne(), que modifica campos específicos, replaceOne() sobrescribe el documento existente por completo, por lo que es necesario incluir todos los campos deseados en el documento de reemplazo.

* **3.4 Metodos adicionales**
  - **db.collection.findOneAndReplace()**
    Este método busca un único documento que coincida con el filtro especificado y lo reemplaza por un nuevo documento. Devuelve el documento original antes de la actualización. Es útil cuando se necesita tanto el documento original como el nuevo.
    ```javascript
    db.collection.findOneAndReplace({ name: "Juan" }, { name: "Pedro", age: 30 })
    ```
  - **db.collection.findOneAndUpdate()**
    Este método busca un único documento que coincida con el filtro especificado y lo actualiza según los cambios proporcionados. Devuelve el documento original antes de la actualización. Es útil para obtener el documento original y realizar cambios en él.
    ```javascript
    db.collection.findOneAndUpdate({ name: "Juan" }, { $set: { age: 30 } })
    ```
  - **db.collection.findAndModify()**
    Este método es una versión más antigua de findOneAndUpdate() y findOneAndReplace() y se encuentra depreacado en las versiones más recientes de MongoDB. Sin embargo, aún se utiliza en algunas aplicaciones heredadas. Permite buscar un documento y modificarlo en una sola operación atómica. La sintaxis básica es similar a findOneAndUpdate():
    ```javascript
    db.collection.findAndModify({ query: { name: "Juan" }, update: { $set: { age: 30 } } })
    ```

## **4\. Operaciones de Eliminación (Delete)**

La operación de "Eliminar" se encarga de remover documentos de una colección en MongoDB. Al igual que las otras operaciones de escritura, las eliminaciones se dirigen a una única colección y son atómicas a nivel de documento.

* **4.1. db.collection.deleteOne()**
  Este método elimina un único documento que coincida con el filtro especificado. Si varios documentos cumplen con el filtro, solo se eliminará el primero que se encuentre. Su introducción también fue en la versión 3.2.7. Un ejemplo de sintaxis básica es:
  
  ```javascript
  db.collection.deleteOne({ name: "Ejemplo" })
  ```

* **4.2. db.collection.deleteMany()**
  Este método elimina todos los documentos que coincidan con el filtro proporcionado. Al igual que deleteOne(), se introdujo en la versión 3.2.7. Un ejemplo de sintaxis básica es:
  
  ```javascript
  db.collection.deleteMany({ status: "inactive" })
  ```
  
  Es fundamental tener precaución al usar deleteMany() y asegurarse de que el filtro sea lo suficientemente específico para evitar la eliminación accidental de datos importantes.

* **4.3 Metodos adicionales**
  - **db.collection.findOneAndDelete()**
    Este método busca un único documento que coincida con el filtro especificado y lo elimina. Devuelve el documento original antes de la eliminación. Es útil cuando se necesita tanto el documento original como la confirmación de su eliminación.
    ```javascript
    db.collection.findOneAndDelete({ name: "Juan" })
    ```

## **5\. Operaciones de Escritura Masiva (Bulk Write Operations)**

El método **db.collection.bulkWrite()** permite realizar múltiples operaciones de inserción, actualización o eliminación en una única solicitud al servidor. Esta funcionalidad, también mencionada como "Bulk Write" en la documentación, ofrece una mejora significativa en el rendimiento para grandes volúmenes de operaciones al reducir el número de viajes de red a la base de datos. Un ejemplo de sintaxis básica podría ser: 

```javascript
db.collection.bulkWrite([
  { insertOne: { document: { name: "Ejemplo 1" } } },
  { updateOne: { filter: { name: "Ejemplo 2" }, update: { $set: { age: 30 } } } },
  { deleteMany: { filter: { status: "inactive" } } }
])
```
Este método permite combinar diferentes tipos de operaciones en una sola llamada, lo que no solo mejora la eficiencia, sino que también garantiza la atomicidad de cada operación individual dentro del contexto de la escritura masiva. Esto significa que si una operación falla, las demás aún se ejecutarán, lo que proporciona un mayor control sobre el manejo de errores y la consistencia de los datos.

## **6\. Tabla Resumen de Métodos CRUD**

| Operación | Método | Descripción |
| :---- | :---- | :---- |
| Crear | insertOne() | Inserta un único documento. |
| Crear | insertMany() | Inserta múltiples documentos. |
| Crear | db.createCollection() | Crea una nueva colección (contenedor de documentos). |
| Leer | find() | Recupera documentos que coinciden con una consulta. |
| Leer | findOne() | Recupera el primer documento que coincide con una consulta. |
| Actualizar | updateOne() | Actualiza el primer documento que coincide con una consulta. |
| Actualizar | updateMany() | Actualiza todos los documentos que coinciden con una consulta. |
| Actualizar | replaceOne() | Reemplaza el primer documento que coincide con una consulta. |
| Eliminar | deleteOne() | Elimina el primer documento que coincide con una consulta. |
| Eliminar | deleteMany() | Elimina todos los documentos que coinciden con una consulta. |
| Escritura Masiva | bulkWrite() | Realiza múltiples operaciones de escritura en una solicitud. |

# Sección 3: INDEXES
---

## **1\. Por qué usar índices en MongoDB**
Los índices en MongoDB son estructuras de datos que mejoran la velocidad de las operaciones de consulta al permitir un acceso más rápido a los documentos dentro de una colección. Sin índices, MongoDB tendría que realizar un escaneo completo de la colección para encontrar los documentos que coinciden con una consulta, lo que puede ser ineficiente y lento, especialmente en colecciones grandes. Al crear índices en campos específicos, MongoDB puede localizar rápidamente los documentos relevantes sin necesidad de recorrer toda la colección.

## **2\. Cómo funcionan los índices en MongoDB**
Los índices aceleran las lecturas mientras ralentizan las escrituras. Internamente, un índice se implementa utilizando una estructura de datos basada en árboles B+ con una complejidad temporal de O(logN).

La creación de nuevos índices en MongoDB puede afectar al rendimiento de escritura porque cada operación de escritura (inserción, actualización, eliminación) también debe actualizar los índices. El impacto exacto en la velocidad de escritura depende de varios factores, incluyendo el número de índices, la complejidad de los índices y la proporción de escrituras frente a lecturas de tu aplicación.

## **3\. Tipos de índices en MongoDB**
MongoDB ofrece varios tipos de índices, cada uno diseñado para satisfacer diferentes necesidades de consulta y rendimiento. Algunos de los tipos más comunes son:
- **Índice de un solo campo(single field index)**: Este es el tipo más básico de índice, que se crea en un solo campo de un documento. Es útil para consultas simples que buscan documentos basados en un único campo.
  ````javascript
  db.collection.createIndex({ fieldName: 1 }) // Índice ascendente
  db.collection.createIndex({ fieldName: -1 }) // Índice descendente
  ````
- **Índice compuesto(compound index)**: Este tipo de índice se crea en múltiples campos de un documento. Es útil para consultas que involucran varios campos y permite optimizar el rendimiento de esas consultas.
  ````javascript
  db.collection.createIndex({ field1: 1, field2: -1 }) // Índice compuesto en field1 (ascendente) y field2 (descendente)
  ````
  - **Regla ESR(Equality, Sort, Range)**: Cuando diseña un índice, es importante seguir la regla ESR. Esta regla establece que los índices deben ser diseñados para satisfacer las consultas de igualdad (E), ordenación (S) y rango (R) en ese orden. Esto significa que los índices deben ser creados para optimizar primero las consultas de igualdad, luego las de ordenación y finalmente las de rango.
  Ejemplo:
    ```javascript
    db.collection.createIndex({ category: 1, price: -1, date: 1 }) // Índice que  sigue la regla ESR: Igualdad en category, ordenación por price y rango en date
    ```
  - **Consultas no soportadas por el índice**: Los índices compuestos no admiten consultas donde el orden de clasificación no coincide con la dirección del índice o la dirección inversa del índice. Supongamos que tenemos el siguiente indice compuesto:
    ```javascript
    db.collection.createIndex({ field1: 1, field2: -1 }) // Índice compuesto en field1 (ascendente) y field2 (descendente)
    ```
    En este caso, no se puede realizar una consulta que ordene por orden descendente en ambos campos, ya que el índice no admite esa dirección de ordenación. Por ejemplo:
    ```javascript
    db.collection.find().sort({ field1: -1, field2: -1 }) // No se puede utilizar el índice compuesto
    ```
    Lo que si se puede hacer es ordenar por el inverso del índice:
    ```javascript
    db.collection.find().sort({ field1: -1, field2: 1 }) // Se puede utilizar el índice compuesto
    ```

- **Índice multikey(multikey index)**: Este tipo de índice se utiliza para indexar campos que contienen arrays. MongoDB crea un índice separado para cada elemento del array, lo que permite realizar consultas eficientes en arrays.
  ````javascript
  db.collection.createIndex({ fieldName: 1 }) // Índice multikey en un campo que contiene un array. fieldName es un campo que contiene un array, por ejemplo, ["a", "b", "c"]
  ````
  El array puede contener elementos de diferentes tipos, como números, cadenas o documentos. MongoDB crea un índice separado para cada elemento del array, lo que permite realizar consultas eficientes en arrays. Ejemplo para array de documentos:
  ```javascript
  db.collection.createIndex({ "fieldName.subField": 1 }) // Índice multikey en un campo que contiene un array de documentos
  ```

- **Índice de texto(text index)**: Este tipo de índice se utiliza para realizar búsquedas de texto completo en campos de tipo cadena. Permite realizar consultas de texto, como búsqueda de palabras clave o frases en documentos.
  ```javascript
  db.collection.createIndex({ fieldName: "text" }) // Índice de texto en un campo
  ```
  - **Búsqueda de texto**: MongoDB permite realizar búsquedas de texto utilizando el operador $text. Esto permite buscar documentos que contengan una o más palabras clave en un campo indexado como texto.
  ```javascript
  db.collection.find({ $text: { $search: "palabra clave" } }) // Busca documentos que contengan "palabra clave"
  ```
  Se pueden especificar multiples campos para la búsqueda de texto, y MongoDB utilizará el índice de texto correspondiente para optimizar la consulta.
  ```javascript
  db.collection.createIndex({ field1: "text", field2: "text" }) // Índice de texto en múltiples campos
  db.collection.find({ $text: { $search: "palabra clave" } }) // Busca documentos que contengan "palabra clave" en field1 o field2
  ```

- **Bonus: Atlas Search**: Atlas Search es una búsqueda basada en relevancia, no una búsqueda de base de datos tradicional. MongoDB construyó esta solución de búsqueda sobre Apache Lucene. La búsqueda comienza con índices de búsqueda, que no son iguales a los índices de base de datos. Aquí hay una buena lectura sobre índices invertidos de búsqueda: https://www.cockroachlabs.com/blog/inverted-indexes/ que te da una buena intuición sobre cómo funciona la búsqueda.

  - Componentes de un Índice de Atlas Search:
    - **Analizador**: Determina cómo se procesa el texto durante la indexación y búsqueda
      - Predeterminado: El analizador estándar divide el texto en términos según los límites de palabras
      - Los analizadores específicos de idioma manejan la derivación, palabras vacías, etc.
      - **Analizadores Built-in**: Atlas Search proporciona varios analizadores incorporados:
        - **Standard**: Es el analizador predeterminado para todos los índices y consultas de Atlas Search.
        - **Simple**: Divide el texto en términos de búsqueda donde encuentra un carácter que no sea una letra.
        - **Whitespace**: Divide el texto en términos de búsqueda donde encuentra un carácter de espacio en blanco.
        - **Keyword**: Indexa los campos de texto como términos únicos.
        - **Language**: Proporciona un conjunto de analizadores de texto específicos para diferentes idiomas.
      - **Tokenizers**: Un tokenizer en el analizador personalizado determina cómo Atlas Search divide el texto en fragmentos discretos para la indexación.
        ```javascript
        "tokenizer": {
          "type": "<tokenizer-type>",
          "<additional-option>": "<value>"
        }
        ```
        Atlas Search soporta los siguientes tipos de tokenizers:
        - **edgeGram**: Divide el texto en tokens de longitud variable desde el inicio del texto.
        - **keyword**: Trata todo el campo como un solo token.
        - **nGram**: Divide el texto en tokens de longitud específica.
        - **regexCaptureGroup**: Usa expresiones regulares para capturar y tokenizar partes específicas del texto.
        - **regexSplit**: Divide el texto usando un patrón de expresión regular como separador.
        - **standard**: El tokenizer predeterminado que divide el texto en palabras.
        - **uaxUrlEmail**: Similar al standard pero preserva URLs y direcciones de correo electrónico como tokens únicos.
        - **whitespace**: Divide el texto donde encuentra espacios en blanco.
    - **Mappings**: Definen cómo deben indexarse los campos del documento
      - Mapeos de tipo (cadena, número, fecha, etc.)
      - Los mapeos dinámicos detectan automáticamente los tipos de campo comunes
      - Mapeos estáticos para control explícito sobre la indexación de campos
      - Los siguientes tipos de datos no son soportados por Atlas Search:
        - Decimal128
        - JavaScript code with scope
        - Max key
        - Min key
        - Regular Expression
        - Timestamp
    - **Campos Almacenados**: Campos que se guardan en el índice para su recuperación
      - Sinónimos para manejar términos equivalentes
      - Configuraciones de sensibilidad a mayúsculas y minúsculas
      - Opciones de normalización para el procesamiento de texto
  
  - Creación de un índice de búsqueda:
    Es ideal saber cómo crear un índice de búsqueda tanto en la interfaz de MongoDB Atlas como en mongosh

    Para verificar si existe un nuevo índice de búsqueda para la colección de películas:
    ```javascript
    db.movies.getSearchIndexes()
    ```
    Para eliminar el índice predeterminado y crear otro mediante la línea de comandos:
    ```javascript
    db.movies.dropSearchIndex("default")
    ```

    Para crear un índice de búsqueda en la colección de películas:
    ```Javascript
      db.movies.createSearchIndex(
      "movieTitleIdx",
      "search",
      {
        mappings: {
          dynamic: false, // no se permiten campos adicionales. Si se coloca en true se agregan todos los campos
          fields: {
            title: {
              type: "string",
            },
            plot: {
              type: "string",
            },
          },
        },
      })
    ```
  
  - Consulta de búsqueda:
    Atlas Search proporciona potentes capacidades de búsqueda de texto completo que van más allá de las consultas básicas. Después de crear un índice de búsqueda, puedes realizar operaciones sofisticadas usando el operador `$search` dentro de un pipeline de agregación.

    La forma más simple de una consulta de búsqueda utiliza el operador `$search` con el operador `$text`:
    ```javascript
       db.movies.aggregate([
        {
          $search: {
            index: "movieTitleIdx", // Reemplaza con el nombre de tu índice de búsqueda
            text: {
              query: "adventure",
              path: "title", // El campo en el que buscar
              fuzzy: {
                maxEdits: 2, // Cuando quieres buscar una palabra similar a la palabra de consulta (por ejemplo, para errores ortográficos)
              },
            },
          },
        },
        {
          $project: {
            title: 1,
            score: {
              $meta: "searchScore",
            }, // Podemos usar $meta para obtener la puntuación de relevancia para cada documento
          },
        },
        },
      ])
    ```
  - Uso de `$search` con operadores compuestos
    Atlas Search también permite combinar múltiples operadores de búsqueda en una sola consulta utilizando el operador `$search` con operadores compuestos. Esto permite realizar búsquedas más complejas y específicas.

    ```javascript
      db.movies.aggregate([
      {
        $search: {
          compound: {
            must: [
              {
                text: {
                  query: "adventure",
                  path: "title"
                }
              }
            ],
              should: [
              {
                text: {
                  query: "fantasy",
                  path: "genres",
                  score: { boost: 1.5 }
                }
              }
            ],
            mustNot: [
              {
                text: {
                  query: "horror",
                  path: "genres"
                }
              }
            ],
            filter: [
              {
                range: {
                  path: "imdbRating",
                  gte: 7.0
                }
              }
            ]
          }
        }
      },
      {
        $project: {
          _id: 0,
          title: 1,
          genres: 1,
          imdbRating: 1,
          year: 1,
          score: { $meta: "searchScore" }
        }
      },
      {
        $sort: { score: -1 }
      },
      {
        $limit: 10
      }
    ])
    ```

    En este ejemplo, la consulta busca películas que contengan "adventure" en el título y "fantasy" en los géneros, pero excluye aquellas que contengan "horror". Además, filtra las películas con una calificación de IMDb mayor o igual a 7.0. La puntuación de relevancia se utiliza para ordenar los resultados.
      

# Sección 4: DATA MODELING
---

## **1\. Relaciones en MongoDB**
En MongoDB, las relaciones entre documentos pueden ser modeladas de dos maneras principales: **embebiendo** (embedding) y **referenciando** (referencing). La elección entre estas dos estrategias depende de varios factores, incluyendo la naturaleza de los datos, la frecuencia de acceso y actualización, y los patrones de consulta.

### **1.1. Tipos de relaciones**
- **Uno a Uno (1:1)**: En una relación uno a uno, un documento en una colección está relacionado con un único documento en otra colección. Esta relación se puede modelar embebiendo el documento relacionado dentro del documento principal o referenciando el ID del documento relacionado.
  - **Embebido**: El documento relacionado se incluye directamente dentro del documento principal.
    ```javascript
    {
      _id: ObjectId("..."),
      name: "John Doe",
      profile: {
        age: 30,
        address: "123 Main St"
      }
    }
    ```
  - **Referenciado**: El documento principal contiene una referencia al ID del documento relacionado.
    ```javascript
    {
      _id: ObjectId("..."),
      name: "John Doe",
      profileId: ObjectId("...")
    }
    ```
- **Uno a Muchos (1:N)**: En una relación uno a muchos, un documento en una colección puede estar relacionado con múltiples documentos en otra colección. Esta relación se puede modelar embebiendo los documentos relacionados dentro del documento principal o referenciando los IDs de los documentos relacionados.
  - **Embebido**: Los documentos relacionados se incluyen directamente dentro del documento principal como un array.
    ```javascript
    {
      _id: ObjectId("..."),
      name: "John Doe",
      orders: [
        { orderId: ObjectId("..."), total: 100 },
        { orderId: ObjectId("..."), total: 200 }
      ]
    }
    ```
  - **Referenciado**: El documento principal contiene un array de referencias a los IDs de los documentos relacionados.
    ```javascript
    {
      _id: ObjectId("..."),
      name: "John Doe",
      orderIds: [ObjectId("..."), ObjectId("...")]
    }
    ```
- **Muchos a Muchos (N:M)**: En una relación muchos a muchos, múltiples documentos en una colección pueden estar relacionados con múltiples documentos en otra colección. Esta relación generalmente se modela utilizando una colección intermedia que contiene referencias a los IDs de ambos documentos.
  - **Embebido**: No es común embeber relaciones muchos a muchos debido a la complejidad y al tamaño potencial de los datos.
  - **Referenciado**: Se utiliza una colección intermedia para almacenar las referencias.
    ```javascript
    // Colección de usuarios
    {
      _id: ObjectId("..."),
      name: "John Doe"
    }
    
    // Colección de grupos
    {
      _id: ObjectId("..."),
      name: "Admins"
    }
    
    // Colección intermedia de membresías
    {
      userId: ObjectId("..."),
      groupId: ObjectId("...")
    }
    ```
### **1.2. Embebido vs Referenciado**
La decisión entre embeber o referenciar documentos en MongoDB depende de varios factores, incluyendo la naturaleza de los datos, la frecuencia de acceso y actualización, y los patrones de consulta. Aquí hay algunas consideraciones clave:
- **Embebido**:
  - **Ventajas**:
    - Mejora el rendimiento de lectura al reducir la necesidad de realizar múltiples consultas.
    - Simplifica la estructura de datos al mantener los datos relacionados juntos.
    - Ideal para datos que son frecuentemente accedidos juntos y no cambian con frecuencia.
  - **Desventajas**:
    - Puede llevar a documentos grandes y difíciles de manejar si los datos embebidos crecen demasiado.
    - Dificulta las actualizaciones de los datos embebidos, ya que se debe actualizar todo el documento principal.
- **Referenciado**:
  - **Ventajas**:
    - Permite una mayor flexibilidad y escalabilidad al separar los datos relacionados.
    - Facilita las actualizaciones de los documentos relacionados sin afectar al documento principal.
    - Ideal para datos que cambian con frecuencia o que tienen una relación compleja.
  - **Desventajas**:
    - Requiere múltiples consultas para recuperar datos relacionados, lo que puede afectar el rendimiento de lectura.
    - Puede complicar la lógica de la aplicación al manejar referencias entre documentos.

### **1.1. Antipatrones de modelado de datos**
Los antipatrones de modelado de datos son prácticas que pueden llevar a problemas de rendimiento, escalabilidad o mantenibilidad en una base de datos. En MongoDB, algunos antipatrones comunes incluyen:
- **Arrays masivos (arrays ilimitados)**: Utilizar arrays que pueden crecer indefinidamente dentro de un documento puede llevar a problemas de rendimiento y límites de tamaño de documentos. Es mejor limitar el tamaño de los arrays o utilizar referencias para manejar grandes colecciones de datos relacionados.
  ```javascript
  // Antipatrón: Array masivo
  {
    _id: ObjectId("..."),
    name: "John Doe",
    comments: [ /* miles de comentarios */ ]
  }
  ```
- **Numero excesivo de colecciones**: Crear demasiadas colecciones para datos que podrían ser modelados en una sola colección puede complicar la estructura de la base de datos y afectar el rendimiento. Es mejor agrupar datos relacionados en una sola colección siempre que sea posible.
  ```javascript
  // Antipatrón: Demasiadas colecciones
  db.users
  db.userProfiles
  db.userSettings
  ```
- **Indices innecesarios**: Crear índices en campos que no son utilizados en consultas puede afectar negativamente el rendimiento de escritura y aumentar el uso de espacio en disco. Es importante analizar las consultas y crear índices solo en los campos que realmente se utilizan.
  ```javascript
  // Antipatrón: Índice innecesario
  db.collection.createIndex({ unusedField: 1 }) // Este índice no se utiliza en ninguna consulta
  ```
- **Documentos inflados**: Tener documentos que contienen demasiada información o datos que no son necesarios para la mayoría de las consultas puede llevar a un uso ineficiente del espacio en disco y afectar el rendimiento. Es mejor dividir los documentos en partes más pequeñas y utilizar referencias cuando sea necesario.
  ```javascript
  // Antipatrón: Documento inflado
  {
    _id: ObjectId("..."),
    name: "John Doe",
    profile: { /* muchos campos innecesarios */ },
    orders: [ /* muchos pedidos */ ]
  }
  ```
- **Separar datos que son frecuentemente accedidos juntos**: Almacenar datos que son frecuentemente accedidos juntos en colecciones separadas puede llevar a un rendimiento deficiente debido a la necesidad de realizar múltiples consultas. Es mejor agrupar estos datos en un solo documento o utilizar embebido para mejorar el rendimiento de lectura.
  ```javascript
  // Antipatrón: Datos separados que son frecuentemente accedidos juntos
  // Colección de usuarios
  {
    _id: ObjectId("..."),
    name: "Juan Pérez",
    email: "juan@email.com"
  }

  // Colección separada de perfiles (información que siempre se necesita con el usuario)
  {
    userId: ObjectId("..."),
    address: "Calle Principal 123",
    phone: "+34 600 123 456",
    birthDate: "1990-05-15"
  }

  // Mejor práctica: Embeber datos frecuentemente accedidos
  {
    _id: ObjectId("..."),
    name: "Juan Pérez",
    email: "juan@email.com",
    profile: {
      address: "Calle Principal 123",
      phone: "+34 600 123 456",
      birthDate: "1990-05-15"
    }
  }
  ```

# Sección 6: DRIVERS
---



## **1\. Introducción al Driver de MongoDB para Node.js**

En el ámbito del desarrollo moderno de aplicaciones web, la combinación de Node.js y MongoDB ha emergido como una opción potente y popular para construir aplicaciones del lado del servidor escalables y eficientes. Node.js, con su arquitectura asíncrona y orientada a eventos, proporciona un entorno de ejecución ideal para manejar peticiones concurrentes, mientras que MongoDB, una base de datos de documentos NoSQL, ofrece flexibilidad y escalabilidad horizontal para gestionar estructuras de datos complejas. Esta sinergia se ve reforzada por el driver oficial de MongoDB para Node.js, que actúa como un puente crucial, permitiendo una comunicación e interacción fluidas entre la capa de aplicación y la base de datos.

Un driver de base de datos sirve como un componente vital en el ecosistema de desarrollo de software, proporcionando los protocolos y funcionalidades necesarios para que una aplicación se conecte e interactúe con un sistema de base de datos específico. Para las aplicaciones de Node.js que buscan aprovechar las capacidades de MongoDB, el driver oficial de MongoDB para Node.js es la solución recomendada y más robusta. Este driver, desarrollado y mantenido por MongoDB Inc., permite a los desarrolladores utilizar JavaScript o TypeScript dentro de su entorno Node.js para realizar una amplia gama de operaciones de base de datos. Su importancia radica en proporcionar una interfaz nativa y optimizada que desbloquea todo el potencial de las características de MongoDB dentro del ecosistema Node.js.

Una de las características clave del driver oficial de MongoDB para Node.js es su interfaz de programación de aplicaciones (API) asíncrona. Este diseño se alinea perfectamente con el modelo de E/S no bloqueante de Node.js, lo que permite que las aplicaciones sigan respondiendo y gestionen numerosas operaciones concurrentes de manera eficiente. El driver ofrece flexibilidad en la gestión de estas operaciones asíncronas al admitir tanto Promises, un enfoque moderno para manejar cálculos asíncronos, como funciones de callback tradicionales, lo que brinda a los desarrolladores opciones que se adaptan a sus preferencias de codificación y requisitos del proyecto.

La estrecha relación entre Node.js y MongoDB se debe en parte a su base compartida en JavaScript. MongoDB almacena los datos en un formato conocido como BSON (Binary JSON), que es una representación binaria de JavaScript Object Notation. Esta compatibilidad inherente simplifica el proceso de serialización y deserialización de datos entre la aplicación y la base de datos, lo que reduce la necesidad de transformaciones de datos complejas y contribuye a una experiencia de desarrollo más ágil. La naturaleza asíncrona del driver oficial es particularmente adecuada para la arquitectura de Node.js. Al permitir que las operaciones de la base de datos se realicen en segundo plano sin detener el hilo de ejecución principal, el driver permite que las aplicaciones de Node.js mantengan un alto rendimiento y escalabilidad, gestionando eficazmente numerosas solicitudes de usuarios simultáneas.

## **2\. Propósito y Ventajas de Usar el Driver Oficial de MongoDB para Node.js**

El driver oficial de MongoDB para Node.js tiene el propósito fundamental de permitir que las aplicaciones de Node.js interactúen eficazmente con las bases de datos de MongoDB. En esencia, el driver facilita el establecimiento de conexiones con varios tipos de implementaciones de MongoDB, ya sea que se ejecuten localmente, estén alojadas en plataformas en la nube como MongoDB Atlas o implementadas dentro de una infraestructura empresarial. Una vez que se establece una conexión, el driver proporciona las herramientas necesarias para ejecutar una amplia gama de comandos de MongoDB directamente desde la aplicación de Node.js. Esto incluye funcionalidades para leer y escribir datos, realizar transformaciones de datos complejas, ejecutar comandos administrativos de la base de datos, gestionar transacciones para garantizar la coherencia de los datos, crear índices para optimizar el rendimiento de las consultas y aprovechar el potente marco de agregación para el análisis avanzado de datos.

Más allá de simplemente ejecutar comandos, el driver también se encarga de la crucial tarea de serialización y deserialización de datos. Convierte sin problemas los datos entre los objetos de JavaScript utilizados en la aplicación y el formato BSON en el que MongoDB almacena los datos. Además, el driver desempeña un papel vital en la gestión de la autenticación y la seguridad, admitiendo varios mecanismos para garantizar un acceso seguro a las bases de datos de MongoDB e incluso ofreciendo funciones como el cifrado de campos del lado del cliente para datos confidenciales.

Elegir el driver oficial de MongoDB para Node.js ofrece numerosas ventajas sobre otros métodos de interacción con MongoDB desde Node.js. En primer lugar, como driver *oficial*, se beneficia del soporte directo y del mantenimiento continuo por parte de MongoDB Inc.. Esto garantiza que el driver siga siendo fiable, reciba actualizaciones oportunas para incorporar las últimas funciones de MongoDB y aborde cualquier vulnerabilidad de seguridad o problema de rendimiento con prontitud. Este nivel de respaldo oficial proporciona a los desarrolladores un mayor grado de confianza en la estabilidad y la longevidad del driver.

En segundo lugar, el driver oficial cuenta con una funcionalidad completa, proporcionando un rico conjunto de API que cubren prácticamente todos los aspectos de las capacidades de MongoDB. Esto incluye soporte para operaciones CRUD (Crear, Leer, Actualizar, Eliminar) fundamentales, así como funciones más avanzadas como indexación, transacciones, registro, monitorización y trabajo con tipos de datos especializados como archivos grandes y colecciones de series temporales. Este extenso conjunto de funciones permite a los desarrolladores aprovechar al máximo la potencia de MongoDB dentro de sus aplicaciones Node.js sin necesidad de depender de bibliotecas externas para las funcionalidades principales.

Otra ventaja significativa es la perfecta integración del driver oficial con las características inherentes de MongoDB. Esto incluye soporte para la API Estable, que permite a las aplicaciones actualizar las versiones del driver y del servidor sin riesgo de problemas de compatibilidad, así como mecanismos de autenticación robustos para asegurar el acceso a la base de datos. El driver también proporciona funcionalidades para monitorizar sus propios eventos y rendimiento, ofreciendo información valiosa sobre la interacción de la aplicación con la base de datos.

Además, el driver oficial de MongoDB para Node.js viene acompañado de una documentación extensa y bien mantenida y una gran cantidad de recursos de aprendizaje. Esto incluye guías de inicio rápido, documentación completa de la API, ejemplos prácticos de uso, tutoriales detallados sobre temas como la agregación, preguntas frecuentes y guías de solución de problemas. MongoDB también ofrece cursos en línea gratuitos a través de MongoDB University y mantiene un Centro de Desarrolladores con tutoriales adicionales y foros de la comunidad. Esta abundancia de recursos reduce significativamente la curva de aprendizaje para los desarrolladores y proporciona un amplio soporte para resolver cualquier problema que pueda surgir.

El driver oficial también se beneficia de una comunidad de usuarios grande y activa. Esta vibrante comunidad proporciona una plataforma para que los desarrolladores busquen ayuda, compartan conocimientos y contribuyan a la mejora continua del driver a través de foros y otros canales. Este entorno colaborativo garantiza que los desarrolladores tengan acceso a una gran cantidad de experiencia y soporte colectivo.

En términos de rendimiento y estabilidad, el driver oficial está rigurosamente probado y optimizado para una interacción eficiente con MongoDB. Si bien pueden existir alternativas impulsadas por la comunidad, el driver oficial está construido con un profundo conocimiento del funcionamiento interno de MongoDB, lo que lleva a un rendimiento y una fiabilidad superiores. La seguridad también es una preocupación primordial, y el driver oficial incorpora las mejores prácticas y admite conexiones seguras y métodos de autenticación, protegiendo los datos confidenciales.

Finalmente, si bien el driver oficial proporciona un conjunto completo de funciones, también está diseñado para ser extensible. Los desarrolladores pueden mejorar aún más sus capacidades integrándolo con otras bibliotecas y herramientas especializadas, como los Mapeadores de Documentos de Objetos (ODM) como Mongoose y Prisma, que proporcionan funciones adicionales para el modelado y la validación de datos. También se pueden utilizar paquetes para el manejo de BSON, la autenticación Kerberos, el cifrado del lado del cliente y la compresión para ampliar la funcionalidad del driver para casos de uso específicos.

La decisión de utilizar el driver oficial de MongoDB para Node.js en lugar de otras opciones ofrece un mayor grado de certeza con respecto a su compatibilidad con futuras actualizaciones y funciones del servidor MongoDB. Debido a que es desarrollado directamente por MongoDB Inc., el driver se actualiza de manera proactiva para admitir nuevas funcionalidades del servidor y abordar cualquier posible problema de compatibilidad. Esto minimiza el riesgo de interrupciones de la aplicación durante las actualizaciones de MongoDB, proporcionando una solución más estable y preparada para el futuro. La extensa documentación oficial y el soporte de una gran comunidad facilitan significativamente el proceso para que los desarrolladores aprendan y utilicen MongoDB de manera efectiva con Node.js. La disponibilidad de guías de inicio rápido, tutoriales detallados y foros activos proporciona una gran cantidad de recursos para el aprendizaje, la resolución de problemas y las mejores prácticas, lo que en última instancia mejora la experiencia del desarrollador y reduce el tiempo de desarrollo. Si bien los ODM como Mongoose ofrecen un mayor nivel de abstracción y características como la definición y validación de esquemas, el driver oficial proporciona un nivel de control más directo y granular sobre las operaciones de MongoDB. Esto puede ser particularmente ventajoso para aplicaciones donde el rendimiento es crítico o donde los desarrolladores requieren un control preciso sobre las interacciones de la base de datos, ya que evita la posible sobrecarga introducida por una capa de abstracción adicional.

## **3\. Entendiendo el URI de Conexión de MongoDB**

El URI (Uniform Resource Identifier) de conexión de MongoDB sirve como un conjunto crucial de instrucciones que el driver oficial de Node.js utiliza para establecer una conexión con una implementación de MongoDB. Esencialmente, le dice al driver cómo localizar y conectarse a la instancia o clúster de MongoDB y dicta ciertos comportamientos durante la conexión. Existen dos formatos principales para los URI de conexión de MongoDB: el formato estándar y el formato SRV (Service).

El **formato estándar de la cadena de conexión** sigue esta estructura general:

```mongodb
mongodb://\[username:password@\]host1\[:port1\]\[,...hostN\[:portN\]\]\[/\[defaultauthdb\]\[?options\]\].
```

Desglosemos cada componente de este URI. El prefijo mongodb:// es un identificador obligatorio que significa el uso del protocolo de conexión estándar de MongoDB. La sección opcional **username:password@** permite la inclusión de credenciales de autenticación. Si la instancia de MongoDB requiere autenticación, el nombre de usuario y la contraseña deben proporcionarse aquí, asegurándose de codificar mediante URL cualquier carácter especial presente en las credenciales. Después de la sección de autenticación se encuentra la parte **host1:port1,...hostN:portN**, que especifica el nombre de host o la dirección IP del servidor MongoDB. Para instancias únicas, esto será un solo host y un número de puerto opcional. Si no se especifica el puerto, se asume el puerto predeterminado de MongoDB, 27017. Al conectarse a un conjunto de réplicas, se deben enumerar varios hosts, separados por comas. El componente opcional **/defaultauthdb** indica la base de datos predeterminada que se utilizará para la autenticación si la opción authSource no se especifica más adelante en el URI.
Finalmente, la sección **?options** permite la inclusión de varias opciones de conexión como pares clave-valor, como **maxPoolSize** para controlar el número de conexiones en el pool de conexiones o w para especificar el nivel de confirmación de escritura o **authSource** para especificar la base de datos que se utilizará para la autenticación. Estas opciones son cruciales para personalizar el comportamiento del driver y optimizar el rendimiento de la conexión según las necesidades específicas de la aplicación.

Ejemplos de URI de conexión estándar incluyen:

```mongodb
mongodb://localhost:27017/mydatabase
mongodb://user:password@host1:27017,host2:27017/?authSource=admin&maxPoolSize=10
```
El primer ejemplo se conecta a una instancia de MongoDB que se ejecuta localmente en el puerto predeterminado, mientras que el segundo ejemplo ilustra una conexión a un conjunto de réplicas con autenticación y opciones adicionales.

El **formato de cadena de conexión SRV** tiene la siguiente forma:

```mongodb
mongodb+srv://\[username:password@\]host\[/\[defaultauthdb\]\[?options\]\]
```

La diferencia clave aquí es el prefijo mongodb+srv:// y la especificación de un solo host. Este host no es una dirección directa a un servidor MongoDB, sino el nombre de host de un registro DNS SRV. Cuando el driver encuentra una cadena de conexión SRV, consulta este registro DNS para descubrir los nombres de host y los números de puerto reales de las instancias mongod (el proceso principal del servidor de MongoDB) o mongos (el enrutador de consultas en configuraciones distribuidas) que componen la implementación de MongoDB. Este formato se utiliza comúnmente con servicios de MongoDB gestionados en la nube como MongoDB Atlas, ya que ofrece flexibilidad en la gestión de la infraestructura subyacente sin requerir que los clientes se reconfiguren cuando cambian las direcciones del servidor. En particular, al utilizar el formato mongodb+srv://, el cifrado TLS/SSL se habilita automáticamente para la conexión. Es importante tener en cuenta que el formato SRV no espera que se especifique un número de puerto directamente después del nombre de host.

Ejemplos de URI de conexión SRV incluyen:

```mongodb
mongodb+srv://usuario:contraseña@cluster0.mongodb.net/miBaseDeDatos

mongodb+srv://admin:P@ssw0rd@micluster.mongodb.net/admin?retryWrites=true&w=majority

mongodb+srv://readonly:readonly@sample-cluster.mongodb.net/sample_airbnb

mongodb+srv://usuario@miproyecto.mongodb.net/test?authSource=admin
```
En estos ejemplos, observa que:

- Siempre comienzan con el prefijo mongodb+srv://
- No se especifica ningún número de puerto (a diferencia del formato estándar)
- Solo se proporciona un nombre de host (el registro DNS SRV)
- El cifrado TLS/SSL se habilita automáticamente
- Se pueden añadir opciones de conexión después del signo de interrogación (?)

La distinción principal entre estos dos formatos radica en cómo el driver descubre los servidores MongoDB. El formato estándar requiere una lista directa de todas las direcciones del servidor, mientras que el formato SRV se basa en la resolución DNS para obtener esta información. Esto hace que el formato SRV sea particularmente ventajoso en entornos dinámicos en la nube donde las direcciones del servidor pueden cambiar con mayor frecuencia.

La elección entre los formatos de URI de conexión estándar y SRV está determinada en gran medida por el entorno en el que se aloja la implementación de MongoDB. El formato SRV es el método preferido para los servicios gestionados en la nube como MongoDB Atlas debido a su flexibilidad inherente y a la habilitación automática del cifrado TLS/SSL, que es crucial para las conexiones seguras basadas en la nube. En contraste, el formato estándar se utiliza más comúnmente para las implementaciones de MongoDB autogestionadas, donde los nombres de host y los números de puerto de los servidores se controlan y conocen directamente. Comprender las diversas opciones de conexión disponibles dentro del URI es esencial para que los desarrolladores ajusten el comportamiento y el rendimiento del driver de MongoDB. Estas opciones permiten la personalización de aspectos como el número máximo de conexiones en el pool, el nivel de reconocimiento de escritura requerido, la especificación del nombre del conjunto de réplicas y la base de datos que se utilizará para la autenticación. Los URI de conexión con formato incorrecto son una causa frecuente de errores de conexión en las aplicaciones Node.js que interactúan con MongoDB. Por ejemplo, intentar incluir un número de puerto en un URI mongodb+srv resultará en un MongoParseError, lo que resalta la importancia de adherirse a la sintaxis correcta para el formato de URI elegido para garantizar el establecimiento exitoso de la conexión.

## **4\. Realización de Operaciones CRUD con el Driver de MongoDB para Node.js**

El driver oficial de MongoDB para Node.js proporciona un conjunto sencillo de métodos para realizar operaciones CRUD (Crear, Leer, Actualizar, Eliminar) fundamentales en las colecciones de MongoDB. Estas operaciones son esenciales para interactuar con los datos almacenados en la base de datos.

### **4.1 Operaciones de Creación** 
Para insertar nuevos documentos en una colección, el driver ofrece dos métodos principales. El método **insertOne** se utiliza para insertar un solo documento. Su sintaxis generalmente implica llamar a `collection.insertOne(document, options, callback)`. El parámetro document es el objeto JavaScript que representa los datos que se van a insertar. Por ejemplo:

```javascript
const result = await db.collection('micoleccion').insertOne({ name: 'John Doe', age: 30 });  
console.log(`Nuevo documento creado con el siguiente id: ${result.insertedId}`);
```

Este fragmento de código muestra cómo insertar un documento en una colección llamada micoleccion.

* **db.collection('micoleccion'):** Selecciona la colección 'micoleccion' dentro de la base de datos db.  
* **.insertOne({ name: 'John Doe', age: 30 }):** Llama al método insertOne para insertar un nuevo documento. El documento es un objeto JavaScript con dos campos: `name` con el valor `John Doe` y `age` con el valor `30`.  
* **await:** Indica que esta es una operación asíncrona y el código esperará a que se complete antes de continuar. Esto requiere que la función contenedora sea async.  
* **const result \=...:** Almacena el resultado de la operación de inserción en la variable result. Este resultado contendrá información sobre la operación, como el ID del documento insertado.  
* **console.log(...):** Imprime en la consola un mensaje indicando que se ha creado un nuevo documento y muestra su ID único (`_id`), que se encuentra en `result.insertedId`.

El método **insertMany**, por otro lado, permite la inserción de varios documentos a la vez. Su sintaxis es `collection.insertMany(documents, options, callback)`. El parámetro `documents` es un array de objetos JavaScript que se van a insertar. Por ejemplo:

```javascript
const result = await db.collection('micoleccion').insertMany([{ name: 'Jane Doe', age: 25 }, { name: 'Peter Pan', age: 100 }]);  
console.log(`${result.insertedCount} nuevos listados creados con los siguientes id(s):`);  
console.log(result.insertedIds);
```

Este ejemplo ilustra la inserción de múltiples documentos en la colección `micoleccion`.

* **db.collection('micoleccion'):** Selecciona la colección `micoleccion`.
* **.insertMany(...):** Llama al método `insertMany`, que toma un array de documentos como argumento.  
* **[{ name: 'Jane Doe', age: 25 }, { name: 'Peter Pan', age: 100 }]:** Este es el array de documentos que se van a insertar. Cada elemento del array es un objeto JavaScript que representa un documento con los campos `name` y `age`.  
* **await const result \=...:** Espera la finalización de la operación asíncrona y almacena el resultado en `result`.  
* **console.log(...):** Imprime en la consola un mensaje que indica cuántos documentos se insertaron (`result.insertedCount`) y muestra los IDs únicos (`_id`) de los documentos insertados, que se encuentran en el objeto `result.insertedIds`.

Ambos métodos, `insertOne` e `insertMany`, también pueden aceptar un objeto options opcional para especificar el nivel de confirmación de escritura y otras configuraciones.

### **4.2 Operaciones de Lectura**
La recuperación de datos de una colección de MongoDB se realiza principalmente mediante los métodos `find` y `findOne`. El método `findOne` se utiliza para recuperar un solo documento que coincida con una consulta especificada. Su sintaxis es `collection.findOne(query, options, callback)`. El parámetro `query` es un objeto JavaScript que define los criterios para seleccionar el documento. Por ejemplo:

```javascript
const result = await db.collection('micoleccion').findOne({ name: 'John Doe' });  
if (result) {  
  console.log('Documento encontrado:', result);  
} else {  
  console.log('No se encontró ningún documento con ese nombre.');  
}
```

Este código muestra cómo buscar un único documento en la colección micoleccion basado en un criterio.

* **db.collection('micoleccion'):** Selecciona la colección `micoleccion`.
* **.findOne({ name: 'John Doe' }):** Llama al método `findOne`, que busca el primer documento que coincida con la consulta proporcionada. La consulta es un objeto `{ name: 'John Doe' }`, lo que significa que buscará un documento donde el campo `name` tenga el valor `John Doe`.  
* **await const result =...:** Espera el resultado de la operación de búsqueda asíncrona y lo almacena en `result`. Si se encuentra un documento, `result` contendrá ese documento, de lo contrario, será `null`.  
* **if (result) {... } else {... }:** Esta estructura condicional verifica si se encontró un documento.  
  * Si `result` no es `null` (es decir, se encontró un documento), se imprime en la consola el mensaje `Documento encontrado:` seguido del documento encontrado.  
  * Si `result` es `null` (no se encontró ningún documento), se imprime el mensaje `No se encontró ningún documento con ese nombre.`.

El método `find` se utiliza para recuperar varios documentos que coincidan con una consulta. Su sintaxis es `collection.find(query, options)`. Este método devuelve un cursor, que es un objeto que permite iterar sobre los resultados. Para obtener los resultados como un array, puede utilizar el método `toArray()` en el cursor:

```javascript
const documents = await db.collection('micoleccion').find({ age: { $gte: 25 } }).toArray();  
console.log('Documentos encontrados:', documents);
```

Este ejemplo ilustra cómo encontrar múltiples documentos en la colección `micoleccion` que cumplen con un criterio específico y cómo convertirlos en un array.

* **db.collection('micoleccion'):** Selecciona la colección `micoleccion`.
* **.find({ age: { \$gte: 25 } }):** Llama al método `find` con una consulta. La consulta es `{ age: { $gte: 25 } }`, que utiliza el operador `$gte` (mayor o igual que) para buscar todos los documentos donde el campo `age` sea mayor o igual a `25`. El método `find` devuelve un cursor a los resultados.  
* **.toArray():** El método `toArray()` se llama en el cursor para convertir todos los documentos coincidentes en un array de JavaScript. Esta es una operación asíncrona.  
* **await const documents \=...:** Espera a que la operación `toArray()` se complete y almacena el array de documentos en la variable documents.  
* **console.log(...):** Imprime en la consola el mensaje `Documentos encontrados:` seguido del array de documentos recuperados.

Alternativamente, puede iterar sobre el cursor directamente utilizando un bucle `forEach`:

```JavaScript
const cursor = db.collection('micoleccion').find({ age: { $gte: 25 } });  
await cursor.forEach(doc => console.log(doc));
```

Este fragmento de código también busca documentos con una `edad` mayor o igual a `25`, pero en lugar de convertirlos directamente a un array, itera sobre el cursor.

* **const cursor \= db.collection('micoleccion').find({ age: { $gte: 25 } });:** Similar al ejemplo anterior, esta línea obtiene un cursor que apunta a todos los documentos que coinciden con la consulta.  
* **await cursor.forEach(doc => console.log(doc));:** El método `forEach` se llama en el cursor. Toma una función de callback que se ejecutará para cada documento (`doc`) que el cursor encuentre. En este caso, la función de callback simplemente imprime cada documento en la consola. La palabra clave `await` se utiliza aquí porque `forEach` en un cursor de MongoDB puede ser asíncrono.

El método `find` también admite opciones para ordenar (`sort`) y proyectar los campos que se devolverán (`projection`).

- Ejemplo de `find` con opciones:
  ```javascript
  const documents = await db.collection('micoleccion').find({ age: { $gte: 25 } })
  .sort({ age: -1 })
  .project({ name: 1, age: 1 })
  .skip(10)  // Omite los primeros 10 documentos
  .limit(5)  // Devuelve solo 5 documentos
  .toArray();
  console.log('Documentos encontrados:', documents);
  ```

### **4.3 Operaciones de Actualización**
La modificación de documentos existentes en una colección se logra mediante los métodos `updateOne` y `updateMany`. El método `updateOne` actualiza un solo documento que coincide con un filtro. Su sintaxis es `collection.updateOne(filter, update, options, callback)`. El parámetro `filter` es un objeto de consulta que identifica el documento que se va a actualizar, y el parámetro `update` es un documento de actualización que especifica los cambios que se van a realizar. Por ejemplo:

```javascript
const result = await db.collection('micoleccion').updateOne({ name: 'John Doe' }, { $set: { age: 31 } });  
console.log(`${result.modifiedCount} documento(s) actualizado(s)`);
```

Este código muestra cómo actualizar el primer documento que coincida con un filtro en la colección `micoleccion`.

* **db.collection('micoleccion'):** Selecciona la colección `micoleccion`.  
* **.updateOne({ name: 'John Doe' }, { $set: { age: 31 } }):** Llama al método `updateOne`.  
  * El primer argumento `{ name: 'John Doe' }` es el filtro. Busca el primer documento donde el campo `name` sea `John Doe`.  
  * El segundo argumento `{ $set: { age: 31 } }` es la actualización. Utiliza el operador `$set` para especificar que el valor del campo age debe establecerse en `31`.  
* **await const result \=...:** Espera la finalización de la operación de actualización asíncrona y almacena el resultado en `result`. El objeto `result` contendrá información sobre la operación, como el número de documentos modificados.  
* **console.log(...):** Imprime en la consola un mensaje que indica cuántos documentos se actualizaron (`result.modifiedCount`). En este caso, como se usa `updateOne`, lo más probable es que sea 0 o 1.

El método `updateMany` actualiza todos los documentos que coinciden con un filtro. Su sintaxis es `collection.updateMany(filter, update, options, callback)`. Por ejemplo:

```javascript
const result = await db.collection('micoleccion').updateMany({ age: { $lt: 30 } }, { $inc: { age: 1 } });  
console.log(`${result.modifiedCount} documento(s) actualizado(s)`);
```

Este ejemplo ilustra cómo actualizar múltiples documentos en la colección micoleccion que cumplen con un criterio específico.

* **db.collection('micoleccion')**: Selecciona la colección `micoleccion`.  
* **.updateMany({ age: { \$lt: 30 } }, { $inc: { age: 1 } })**: Llama al método `updateMany`.  
  * El primer argumento `{ age: { $lt: 30 } }` es el filtro. Utiliza el operador `$lt` (menor que) para buscar todos los documentos donde el campo age sea menor que 30.  
  * El segundo argumento `{ $inc: { age: 1 } }` es la actualización. Utiliza el operador $inc para incrementar el valor del campo `age` en 1 para todos los documentos que coincidan con el filtro.  
* **await const result \=...**: Espera el resultado de la operación de actualización asíncrona y lo almacena en `result`.  
* **console.log(...)**: Imprime en la consola un mensaje que indica cuántos documentos se actualizaron (`result.modifiedCount`).

Tanto `updateOne` como `updateMany` admiten varias opciones, incluido `upsert` para insertar un nuevo documento si no se encuentra ningún documento coincidente.

### **4.4 Operaciones de Eliminación:** 
La eliminación de documentos de una colección se realiza mediante los métodos `deleteOne` y `deleteMany`. El método `deleteOne` elimina un solo documento que coincide con un filtro. Su sintaxis es `collection.deleteOne(filter, options, callback)`. El parámetro `filter` especifica los criterios para el documento que se va a eliminar. Por ejemplo:

```javascript
const result = await db.collection('micoleccion').deleteOne({ name: 'Peter Pan' });  
console.log(`${result.deletedCount} documento(s) eliminado(s)`);
```

Este código muestra cómo eliminar el primer documento que coincida con un filtro en la colección `micoleccion`.

* **db.collection('micoleccion')**: Selecciona la colección `micoleccion`.  
* **.deleteOne({ name: 'Peter Pan' })**: Llama al método `deleteOne` con un filtro. El filtro `{ name: 'Peter Pan' }` busca el primer documento donde el campo `name` sea `Peter Pan` para eliminarlo.  
* **await const result \=...**: Espera la finalización de la operación de eliminación asíncrona y almacena el resultado en `result`. El objeto `result` contendrá información sobre la operación, como el número de documentos eliminados.  
* **console.log(...)**: Imprime en la consola un mensaje que indica cuántos documentos se eliminaron (`result.deletedCount`). En este caso, con `deleteOne`, lo más probable es que sea 0 o 1.

El método `deleteMany` elimina todos los documentos que coinciden con un filtro. Su sintaxis es `collection.deleteMany(filter, options, callback)`. Por ejemplo:

```javascript
const result = await db.collection('micoleccion').deleteMany({ age: { $gte: 100 } });  
console.log(`${result.deletedCount} documento(s) eliminado(s)`);
```

Este ejemplo ilustra cómo eliminar múltiples documentos de la colección `micoleccion` que cumplen con un criterio específico.

* **db.collection('micoleccion')**: Selecciona la colección `micoleccion`.  
* .**deleteMany({ age: { \$gte: 100 } })**: Llama al método `deleteMany` con un filtro. El filtro `{ age: { $gte: 100 } } `utiliza el operador `$gte` para buscar todos los documentos donde el campo `age` sea mayor o igual a `100` y los elimina.  
* **await const result \=...**: Espera el resultado de la operación de eliminación asíncrona y lo almacena en `result`.  
* **console.log(...)**: Imprime en la consola un mensaje que indica cuántos documentos se eliminaron (`result.deletedCount`).

Similar a otras operaciones CRUD, `deleteOne` y `deleteMany` también pueden aceptar un objeto `options` para configurar el nivel de confirmación de escritura.

Los métodos del driver oficial para las operaciones CRUD proporcionan una forma directa e intuitiva de interactuar con los datos de MongoDB. La denominación de estos métodos refleja claramente sus correspondientes operaciones de base de datos, lo que facilita a los desarrolladores su comprensión y utilización efectiva. La disponibilidad de varias opciones para cada operación permite un control preciso sobre las interacciones de la base de datos, lo que permite a los desarrolladores adaptar el comportamiento a las necesidades específicas de la aplicación, como garantizar la coherencia de los datos a través de los niveles de confirmación de escritura o manejar casos en los que un documento podría no existir utilizando la funcionalidad de `upsert`. La naturaleza asíncrona de estas operaciones, ya sea manejada a través de `Promises` o `callbacks`, es fundamental para el diseño del driver, asegurando que las aplicaciones Node.js sigan siendo no bloqueantes y responsivas incluso al realizar tareas intensivas de base de datos.

## **5\. Aprovechando el Framework de Agregación con el Driver de MongoDB para Node.js**

El framework de agregación de MongoDB es una herramienta poderosa que permite a los desarrolladores procesar y transformar datos dentro de la base de datos a través de una serie de etapas. Este framework proporciona una forma de realizar análisis de datos complejos y generar resultados resumidos de manera eficiente. El driver oficial de MongoDB para Node.js proporciona el método `aggregate` para utilizar este framework dentro de las aplicaciones de Node.js.

Un **pipeline de agregación** consiste en una secuencia de **etapas**, donde cada etapa realiza una operación específica sobre los datos. La salida de una etapa se pasa como entrada a la siguiente etapa del pipeline. Algunas etapas de agregación comunes incluyen `$match`, que filtra documentos basados en una condición especificada; `$group`, que agrupa documentos por un identificador especificado y aplica expresiones acumuladoras para calcular valores como sumas o promedios; `$sort`, que ordena documentos basados en campos especificados; `$project`, que remodela documentos agregando, eliminando o renombrando campos; `$limit`, que restringe el número de documentos pasados a la siguiente etapa; `$unwind`, que deconstruye un campo de array para generar un documento separado para cada elemento; `$lookup`, que realiza una unión externa izquierda con otra colección; y `$out`, que escribe los resultados de la agregación en una colección especificada. Dentro de la etapa `$group`, los operadores acumuladores como `$sum`, `$avg`, `$min`, `$max` y `$count` se utilizan para realizar cálculos sobre los datos agrupados.

La sintaxis para usar el framework de agregación con el driver de Node.js implica llamar al método `aggregate` en una colección: `collection.aggregate(pipeline, options, callback)`. El parámetro `pipeline` es un array de objetos de etapa, donde cada objeto define una etapa de agregación específica y sus parámetros asociados. Por ejemplo, para agrupar restaurantes por su calificación de estrellas (dentro de la categoría "Panadería") y contar el número de restaurantes en cada calificación, se podría usar el siguiente pipeline:


```javascript
const pipeline = [  
  { $match: { categories: "Bakery" } },  
  { $group: { _id: "$stars", count: { $sum: 1 } } }  
];
const aggCursor = db.collection("restaurants").aggregate(pipeline);  
await aggCursor.forEach(doc => console.log(doc));
```

Este ejemplo muestra un pipeline de agregación simple para analizar datos de restaurantes.

* **const pipeline = [...]**: Define un array llamado pipeline. Este array contiene las etapas de agregación que se ejecutarán en secuencia.  
  * **{ \$match: { categories: "Bakery" } }**: Esta es la primera etapa, `$match`. Filtra los documentos de la colección `restaurants` para incluir solo aquellos donde el campo `categories` contenga el valor `Bakery`.  
  * **{ \$group: { _id: "\$stars", count: { \$sum: 1 } } }**: Esta es la segunda etapa, `$group`. Agrupa los documentos filtrados por el valor del campo `stars`.  
    * **_id: "$stars"**: Especifica que el campo `_id` en los resultados agrupados será el valor del campo `stars` de los documentos originales.  
    * **count: { \$sum: 1 }**: Utiliza el operador acumulador `$sum` para contar el número de documentos en cada grupo. Para cada documento en un grupo, se suma 1 al contador, y el resultado se almacena en el campo `count`.  
* **const aggCursor \= db.collection("restaurants").aggregate(pipeline);**: Llama al método `aggregate` en la colección `restaurants` con el pipeline definido. Esto devuelve un cursor (`aggCursor`) que se puede utilizar para acceder a los resultados de la agregación.  
* **await aggCursor.forEach(doc => console.log(doc));**: Itera sobre cada documento (`doc`) en el cursor de agregación y lo imprime en la consola. `forEach` es un método que se puede usar en los cursores de MongoDB para procesar cada resultado.

Otro ejemplo práctico, consiste en encontrar el precio promedio de los listados en un mercado específico (por ejemplo, Sydney, Australia), ordenados por precio y limitado a un cierto número de resultados:


```javascript
const pipeline = [  
  { '$match': {  
    'bedrooms': 1,  
    'address.country': 'Australia',  
    'address.market': 'Sydney',  
    'address.suburb': { '$exists': 1, '$ne': '' },  
    'room_type': 'Entire home/apt'  
  } },  
  { '$group': {  
    '_id': '$address.suburb',  
    'averagePrice': { '$avg': '$price' }  
  } },  
  { '$sort': { 'averagePrice': 1 } },  
  { '$limit': 10 }  
];
const aggCursor = db.collection("listingsAndReviews").aggregate(pipeline);  
await aggCursor.forEach(doc => console.log(doc));
```

Este pipeline de agregación es más complejo y tiene múltiples etapas para analizar datos de listados.

* **$match Stage:**  
  * Filtra los documentos para incluir solo aquellos que cumplen con varios criterios:  
    * `bedrooms`: Debe ser igual a 1.  
    * `address.country`: Debe ser igual a 'Australia'.  
    * `address.market`: Debe ser igual a 'Sydney'.  
    * `address.suburb`: Debe existir y no ser una cadena vacía.  
    * `room_type`: Debe ser igual a 'Entire home/apt'.
* **$group Stage:**
  * Agrupa los documentos filtrados por el campo `address.suburb`.  
  * Calcula el precio promedio (`averagePrice`) de los listados en cada suburbio utilizando el operador acumulador `$avg` en el campo `price`.
* **$sort Stage:**
  * Ordena los resultados agrupados por el campo `averagePrice` en orden ascendente (1).
* **$limit Stage:**
  * Limita el número de documentos devueltos a 10. Esto significa que solo se mostrarán los 10 suburbios con el precio promedio más bajo.
* **const aggCursor \= db.collection("listingsAndReviews").aggregate(pipeline);**: Llama al método `aggregate` en la colección `listingsAndReviews` con el pipeline definido. Esto devuelve un cursor (`aggCursor`) que se puede utilizar para acceder a los resultados de la agregación.
* **await aggCursor.forEach(doc => console.log(doc));**: Itera sobre cada documento (`doc`) en el cursor de agregación y lo imprime en la consola.


Un ejemplo adicional, ilustra cómo usar `$unwind` para trabajar con array data. En este caso, se busca un menú específico y se filtran los subenlaces dentro de ese menú. El pipeline de agregación es el siguiente:


```javascript
const pipeline = [  
  { '$unwind': { 'path': '$sublinks' } },  
  { '$match': { '$and': [ { 'menuitemname': 'Dashboard' }, { 'sublinks.sublinkid': 1 } ] } },  
  { '$project': { '_id': 0, 'menuitemname': 1, 'sublinks': 1 } }  
];  
const aggCursor = db.collection("adminnavbar").aggregate(pipeline);  
await aggCursor.toArray();
```

Este pipeline de agregación demuestra el uso de la etapa `$unwind` para trabajar con arrays dentro de los documentos.

* **$unwind Stage:**  
  * Descompone el array `sublinks` en documentos separados. Esto significa que si un documento tiene un array `sublinks` con múltiples elementos, se generarán múltiples documentos, cada uno conteniendo un solo elemento del array.
* **$match Stage:**
  * Filtra los documentos para incluir solo aquellos que cumplen con dos condiciones:  
    * `menuitemname` debe ser igual a 'Dashboard'.  
    * `sublinks.sublinkid` debe ser igual a 1.
* **$project Stage:**
  * Especifica qué campos incluir en los resultados finales. En este caso, se incluyen `menuitemname` y `sublinks`, pero se excluye el campo `_id` (se establece en 0).
* **const aggCursor \= db.collection("adminnavbar").aggregate(pipeline);**: Llama al método `aggregate` en la colección `adminnavbar` con el pipeline definido. Esto devuelve un cursor (`aggCursor`) que se puede utilizar para acceder a los resultados de la agregación.
* **await aggCursor.toArray();**: Convierte el cursor en un array de documentos y espera a que se complete la operación asíncrona. Esto devuelve todos los documentos resultantes del pipeline de agregación.

* **Resultado**:
  ```json
  [
    { "menuitemname": "Dashboard", "sublinks": { "sublinkid": 1,  "name": "Overview" } },
    { "menuitemname": "Dashboard", "sublinks": { "sublinkid": 1,  "name": "Reports" } }
  ]
  ```

El framework de agregación ofrece una ventaja significativa al permitir que el procesamiento complejo de datos se realice directamente dentro de la base de datos de MongoDB. Esto minimiza la cantidad de datos que necesita transferirse a la aplicación Node.js para su procesamiento, lo que lleva a un mejor rendimiento, especialmente cuando se trata de grandes conjuntos de datos. Al comprender y utilizar eficazmente las diversas etapas de agregación, los desarrolladores pueden construir pipelines sofisticados para extraer información valiosa y transformar datos para satisfacer las necesidades específicas de sus aplicaciones. La etapa `$out` proporciona una capacidad adicional poderosa al permitir la persistencia de los resultados de la agregación en nuevas colecciones, lo que puede ser útil para crear vistas materializadas o preparar datos para un análisis o informes posteriores sin la necesidad de volver a ejecutar el pipeline de agregación repetidamente.

### **5.1\. Etapas Comunes de Agregación de MongoDB**

| Nombre de la Etapa | Descripción | Caso de Uso de Ejemplo |
| :---- | :---- | :---- |
| $match | Filtra documentos basados en una condición especificada. | Seleccionar pedidos dentro de un rango de fechas específico. |
| $group | Agrupa documentos por un identificador especificado y aplica expresiones acumuladoras. | Calcular las ventas totales por categoría de producto. |
| $sort | Ordena documentos basados en campos especificados. | Ordenar los resultados de búsqueda por relevancia o precio. |
| $project | Remodela cada documento en el flujo agregando, eliminando o renombrando campos. | Seleccionar campos específicos para incluirlos en la salida. |
| $limit | Limita el número de documentos pasados a la siguiente etapa. | Mostrar solo los 10 resultados principales. |
| $unwind | Deconstruye un campo de array para generar un documento para cada elemento del array. | Procesar cada artículo en el array de artículos de un pedido. |
| $lookup | Realiza una unión externa izquierda a otra colección en la misma base de datos. | Combinar la información del cliente con los detalles de su pedido. |
| $out | Escribe los resultados del pipeline de agregación en una colección especificada. | Crear una vista materializada de datos agregados. |
| $sum | Operador acumulador para calcular la suma de valores. | Calcular el importe total de un pedido. |
| $avg | Operador acumulador para calcular el promedio de valores. | Encontrar la calificación promedio de un producto. |
| $count | Operador acumulador para contar el número de documentos. | Determinar el número de usuarios que iniciaron sesión en un día en particular. |

## **6\. Casos Prácticos de Operaciones CRUD y Agregación**

Las operaciones CRUD y el framework de agregación son bloques fundamentales para una amplia variedad de aplicaciones del mundo real construidas con Node.js y MongoDB. Exploremos algunos ejemplos ilustrativos de cómo se aplican estas operaciones en escenarios típicos.

En sistemas de **gestión de usuarios**, las operaciones CRUD son esenciales para manejar datos de usuarios. La creación de una nueva cuenta de usuario implica usar `insertOne` para añadir la información del usuario a una colección de usuarios. La recuperación de perfiles de usuario, ya sea para visualización o autenticación, utiliza `findOne` o `find` para consultar la colección de usuarios basándose en identificadores únicos como nombres de usuario o direcciones de correo electrónico. La actualización de información de usuario, como contraseñas o detalles de perfil, se realiza utilizando `updateOne` con filtros apropiados. Finalmente, eliminar cuentas de usuario inactivas o no deseadas implica `deleteOne` o `deleteMany` basándose en criterios específicos.

Para administrar un **catálogo de productos** en una aplicación de comercio electrónico, las operaciones CRUD son igualmente cruciales. Añadir nuevos productos al catálogo implica usar `insertOne` o `insertMany` para almacenar detalles del producto como nombre, descripción, precio y niveles de inventario en una colección de productos. Mostrar detalles del producto en el sitio web o en resultados de búsqueda requiere usar `findOne` para recuperar información de un producto específico o `find` para listar múltiples productos basados en categorías o términos de búsqueda. Actualizar el inventario del producto o información de precios se realiza usando `updateOne` o `updateMany`. Eliminar productos descontinuados del catálogo implica `deleteOne` o `deleteMany`.

En sistemas de **procesamiento de pedidos**, las operaciones CRUD se utilizan para gestionar pedidos de clientes. Crear un nuevo pedido cuando un cliente completa una compra implica usar `insertOne` para añadir los detalles del pedido, incluyendo los artículos comprados, información del cliente y dirección de envío, a una colección de pedidos. Recuperar detalles del pedido para un cliente o para fines de cumplimiento utiliza `findOne` o `find` basado en IDs de pedido o IDs de cliente. Actualizar el estado del pedido, como marcar un pedido como enviado o entregado, se realiza usando `updateOne`. Archivar pedidos completados, quizás para registros históricos o para mejorar el rendimiento en la colección de pedidos activos, podría implicar usar `deleteMany` con un filtro para pedidos completados.

Los **Sistemas de Gestión de Contenido (CMS)** también dependen en gran medida de las operaciones CRUD para gestionar artículos, páginas y otro contenido. Crear nuevo contenido implica `insertOne` para añadir el contenido a una colección de contenido. Mostrar contenido en el sitio web utiliza `findOne` o `find` basado en slugs de URL u otros identificadores. Actualizar contenido existente se realiza usando `updateOne`. Eliminar contenido antiguo u obsoleto implica `deleteOne` o `deleteMany`.

Más allá de la gestión básica de datos, el framework de agregación proporciona capacidades poderosas para análisis y transformación de datos en varios casos de uso. Por ejemplo, para calcular el **valor promedio de pedido** en una aplicación de comercio electrónico, se podría usar un pipeline de agregación en la colección de pedidos. Este pipeline podría involucrar una etapa `$group` que agrupe pedidos (quizás por fecha o segmento de cliente) y use el acumulador `$avg` para calcular el total promedio de pedidos.

Para identificar **productos más vendidos**, un pipeline de agregación en una colección de ítems_de_pedido (o potencialmente la colección de pedidos si contiene detalles de artículos) podría usar una etapa `$group` para agrupar por ID de producto, un acumulador `$sum` para contar el número de veces que aparece cada producto en los pedidos, y una etapa `$sort` para ordenar los resultados por el conteo total en orden descendente.

Para **analizar la actividad del usuario**, como rastrear inicios de sesión o uso de funciones, un pipeline de agregación en una colección de actividad_de_usuario podría usar una etapa `$match` para filtrar actividad dentro de un período de tiempo específico, una etapa `$group` para agrupar por ID de usuario o tipo de actividad, y un acumulador `$count` para contar las ocurrencias dentro de cada grupo.

Generar **informes** sobre métricas clave a menudo implica combinar múltiples etapas de agregación. Por ejemplo, para crear un informe sobre tráfico del sitio web por fuente a lo largo del tiempo, un pipeline en una colección de visitas_al_sitio_web podría usar `$match` para filtrar por rango de fechas, `$group` para agrupar por fuente de tráfico y fecha, y `$count` para contar el número de visitas para cada grupo.

La naturaleza orientada a documentos de MongoDB, junto con la flexibilidad del driver oficial de Node.js, lo hace altamente adaptable a una amplia gama de escenarios de aplicación del mundo real, desde gestionar entidades de datos fundamentales como usuarios y productos hasta procesar transacciones y manejar contenido dinámico. El framework de agregación amplía aún más estas capacidades proporcionando herramientas robustas para extraer inteligencia empresarial valiosa y generar informes perspicaces a partir de los datos almacenados, permitiendo la toma de decisiones basada en datos. Aunque los ejemplos proporcionados aquí ofrecen un vistazo a las aplicaciones prácticas de las operaciones CRUD y de agregación, las implementaciones del mundo real a menudo involucran combinaciones más complejas y matizadas de estas técnicas, adaptadas a la lógica de negocio específica y los requisitos de datos de la aplicación.


