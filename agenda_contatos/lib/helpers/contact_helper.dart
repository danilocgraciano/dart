import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String TABLE = 'contact';
const String ID_COLUMN = 'id';
const String NAME_COLUMN = 'name';
const String EMAIL_COLUMN = 'email';
const String PHONE_COLUMN = 'phone';
const String IMG_COLUMN = 'img';

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'agenda.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute('CREATE TABle $TABLE($ID_COLUMN INTEGER PRIMARY KEY, $NAME_COLUMN TEXT, $EMAIL_COLUMN TEXT, $PHONE_COLUMN TEXT, $IMG_COLUMN TEXT)');
    });
  }

  Future<Contact> save(Contact contact) async {
    Database db = await ContactHelper._instance.db;
    contact.id = await db.insert(TABLE, contact.toMap());
    return contact;
  }

  Future<Contact> get(int id) async {
    Database db = await ContactHelper._instance.db;
    List<Map> maps = await db.query(TABLE,
        columns: [
          ID_COLUMN,
          NAME_COLUMN,
          EMAIL_COLUMN,
          PHONE_COLUMN,
          IMG_COLUMN
        ],
        where: '$ID_COLUMN = ?',
        whereArgs: [id]);

    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> delete(int id) async {
    Database db = await ContactHelper._instance.db;
    return await db.delete(TABLE, where: '$ID_COLUMN = ?', whereArgs: [id]);
  }

  Future<int> update(Contact contact) async {
    Database db = await ContactHelper._instance.db;
    return await db.update(TABLE, contact.toMap(),
        where: '$ID_COLUMN = ?', whereArgs: [contact.id]);
  }

  Future<List> all() async {
    Database db = await ContactHelper._instance.db;
    List listMap = await db.rawQuery('SELECT * FROM $TABLE');
    List<Contact> contacts = List();

    for (Map m in listMap) {
      contacts.add(Contact.fromMap(m));
    }
    return contacts;
  }

  Future<int> count() async {
    Database db = await ContactHelper._instance.db;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $TABLE'));
  }

  Future close() async {
    Database db = await ContactHelper._instance.db;
    db.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[ID_COLUMN];
    name = map[NAME_COLUMN];
    email = map[EMAIL_COLUMN];
    phone = map[PHONE_COLUMN];
    img = map[IMG_COLUMN];
  }

  Map toMap() {
    Map<String, dynamic> map = Map();
    map[NAME_COLUMN] = name;
    map[EMAIL_COLUMN] = email;
    map[PHONE_COLUMN] = phone;
    map[IMG_COLUMN] = img;

    if (id != null) {
      map[ID_COLUMN] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
