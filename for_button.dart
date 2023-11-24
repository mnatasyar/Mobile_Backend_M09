// Pada showEditDialog, ubah letak dan ikon tombolnya
actions: <Widget>[
  TextButton(
    child: const Text('Batal'),
    onPressed: () {
      Navigator.of(context).pop();
    },
  ),
  TextButton(
    child: const Text('Hapus'),
    onPressed: () async {
      await deleteItemOnList(event);
      Navigator.of(context).pop();
    },
  ),
  TextButton(
    child: const Text('Simpan'),
    onPressed: () async {
      event.judul = judulController.text;
      event.keterangan = keteranganController.text;
      event.tanggal = tanggalController.text;
      event.pembicara = pembicaraController.text;

      await updateItem(event);
      Navigator.of(context).pop();
    },
  ),
],

// Pada ListView.builder, sesuaikan letak tombolnya
itemBuilder: (context, position) {
  return ListTile(
    onTap: () {
      showEditDialog(details[position]);
    },
    title: Text(details[position].judul),
    subtitle: Text(
      "${details[position].keterangan}\nHari : ${details[position].tanggal}\nPembicara : ${details[position].pembicara}",
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            await showDeleteConfirmationDialog(details[position].id!);
          },
        ),
        SizedBox(width: 8),
        Checkbox(
          onChanged: (bool? value) {
            updateEvent(position);
          },
          value: details[position].is_like,
        ),
      ],
    ),
  );
},
