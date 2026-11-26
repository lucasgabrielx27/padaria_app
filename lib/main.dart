import 'package:flutter/material.dart';

void main() => runApp(const PadariaApp());

/// Modelo do registro (Produto, Tipo e Sabor).
class Registro {
  final String produto;
  final String tipo;
  final String sabor;

  const Registro({
    required this.produto,
    required this.tipo,
    required this.sabor,
  });
}

class PadariaApp extends StatelessWidget {
  const PadariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Padaria',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const ListaPage(),
    );
  }
}

/// Tela de listagem: exibe, adiciona, edita e exclui registros.
class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  // Lista em memória (não persiste após fechar o app).
  final List<Registro> _registros = [
    const Registro(produto: 'Bolo', tipo: 'Confeitaria', sabor: 'Chocolate'),
  ];

  /// Abre o formulário. Se [indice] for informado, é edição.
  Future<void> _abrirFormulario({int? indice}) async {
    final Registro? resultado = await Navigator.push<Registro>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioPage(
          registro: indice != null ? _registros[indice] : null,
        ),
      ),
    );

    // Usuário voltou sem salvar.
    if (resultado == null) return;

    setState(() {
      if (indice == null) {
        _registros.add(resultado); // cadastro
      } else {
        _registros[indice] = resultado; // edição: substitui, sem duplicar
      }
    });
  }

  Future<void> _excluir(int indice) async {
    final bool? confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text('Deseja remover "${_registros[indice].produto}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      setState(() => _registros.removeAt(indice));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Padaria'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _registros.isEmpty
          ? const Center(child: Text('Nenhum registro cadastrado.'))
          : ListView.separated(
              itemCount: _registros.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = _registros[i];
                return ListTile(
                  leading: const Icon(Icons.bakery_dining),
                  title: Text(
                    r.produto,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Tipo: ${r.tipo}\nSabor: ${r.sabor}'),
                  isThreeLine: true,
                  onTap: () => _abrirFormulario(indice: i),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Excluir',
                    onPressed: () => _excluir(i),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }
}

/// Tela de formulário usada tanto para cadastro quanto para edição.
class FormularioPage extends StatefulWidget {
  final Registro? registro;

  const FormularioPage({super.key, this.registro});

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _produtoCtrl;
  late final TextEditingController _tipoCtrl;
  late final TextEditingController _saborCtrl;

  bool get _editando => widget.registro != null;

  @override
  void initState() {
    super.initState();
    _produtoCtrl = TextEditingController(text: widget.registro?.produto ?? '');
    _tipoCtrl = TextEditingController(text: widget.registro?.tipo ?? '');
    _saborCtrl = TextEditingController(text: widget.registro?.sabor ?? '');
  }

  @override
  void dispose() {
    _produtoCtrl.dispose();
    _tipoCtrl.dispose();
    _saborCtrl.dispose();
    super.dispose();
  }

  /// Rejeita vazio ou apenas espaços.
  String? _validar(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      Registro(
        produto: _produtoCtrl.text.trim(),
        tipo: _tipoCtrl.text.trim(),
        sabor: _saborCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar registro' : 'Novo registro'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _produtoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Produto',
                  border: OutlineInputBorder(),
                ),
                validator: _validar,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tipoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                validator: _validar,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _saborCtrl,
                decoration: const InputDecoration(
                  labelText: 'Sabor',
                  border: OutlineInputBorder(),
                ),
                validator: _validar,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: Text(_editando ? 'Salvar alterações' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}