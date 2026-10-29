import re
p='frontend/lib/features/reports_and_alerts/break_binding/presentation/brake_binding_screen.dart'
s=open(p).read()
old='''          return SingleChildScrollView(
            child: Padding('''
new='''          return RefreshIndicator(
            onRefresh: () async {
              if (!state.isLoadingCoaches) {
                context.read<BrakeBindingBloc>().add(LoadInitData());
              }
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: SingleChildScrollView(
              child: Padding('''
assert old in s, 'old1 not found'
s=s.replace(old,new,1)
marker='''                  _buildActiveFaultsSection(state),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
'''
repl='''                  _buildActiveFaultsSection(state),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          );
'''
assert marker in s, 'marker not found'
s=s.replace(marker,repl,1)
open(p,'w').write(s)
print('done')