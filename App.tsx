import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View } from 'react-native';

export default function App() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>pettrainer</Text>
      <Text style={styles.subtitle}>Szkielet projektu</Text>
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#f1f3ee',
    gap: 8,
  },
  title: {
    fontSize: 28,
    fontWeight: '600',
    color: '#14181a',
  },
  subtitle: {
    fontSize: 15,
    color: '#6b746e',
  },
});
