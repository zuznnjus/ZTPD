import java.io.IOException;

import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.runtime.client.EPRuntime;
import com.espertech.esper.runtime.client.EPRuntimeProvider;
import com.espertech.esper.common.client.EPCompiled;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.compiler.client.CompilerArguments;
import com.espertech.esper.compiler.client.EPCompileException;
import com.espertech.esper.compiler.client.EPCompilerProvider;
import com.espertech.esper.runtime.client.*;

public class Main {
    public static void main(String[] args) throws IOException {

        Configuration configuration = new Configuration();
        configuration.getCommon().addEventType(KursAkcji.class);
        EPRuntime epRuntime = EPRuntimeProvider.getDefaultRuntime(configuration);

        String zad5 = "select istream data, kursZamkniecia, spolka, max(kursZamkniecia)-kursZamkniecia as roznica " +
                "from KursAkcji.win:ext_timed_batch(data.getTime(), 1 day)";

        String zad6 = "select istream data, kursZamkniecia, spolka, max(kursZamkniecia)-kursZamkniecia as roznica " +
                "from KursAkcji(spolka = 'IBM' OR spolka='Honda' or spolka='Microsoft').win:ext_timed_batch(data.getTime(), 1 day)";

        String zad7a = "select istream data, kursZamkniecia, kursOtwarcia, spolka " +
                "from KursAkcji.win:ext_timed_batch(data.getTime(), 1 day) " +
                "where kursZamkniecia > kursOtwarcia";

        String zad7b = "select istream data, kursZamkniecia, kursOtwarcia, spolka " +
                "from KursAkcji.win:ext_timed_batch(data.getTime(), 1 day) " +
                "where KursAkcji.czyWiekszyKursZamkniecia(kursZamkniecia, kursOtwarcia)";

        String zad8 = "select istream data, kursZamkniecia, spolka, max(kursZamkniecia)-kursZamkniecia as roznica " +
                "from KursAkcji(spolka = 'PepsiCo' OR spolka = 'CocaCola').win:ext_timed(data.getTime(), 7 days)";

        String zad9 = "select istream data, kursZamkniecia, spolka " +
                "from KursAkcji(spolka = 'PepsiCo' OR spolka = 'CocaCola').win:ext_timed_batch(data.getTime(), 1 day) " +
                "having max(kursZamkniecia) = kursZamkniecia";

        String zad10 = "select max(kursZamkniecia) as maksimum " +
                "from KursAkcji.win:ext_timed_batch(data.getTime(), 7 days)";

        String zad11 = "select istream pepsi.kursZamkniecia as kursPep, cola.kursZamkniecia as kursCoc, cola.data " +
                "from KursAkcji(spolka = 'PepsiCo').win:length(1) as pepsi join KursAkcji(spolka = 'CocaCola').win:length(1) as cola on pepsi.data=cola.data " +
                "where pepsi.kursZamkniecia > cola.kursZamkniecia";

        String zad12 = "select istream curr.data, curr.kursZamkniecia, curr.spolka, curr.kursZamkniecia-first.kursZamkniecia as roznica " +
                "from KursAkcji(spolka = 'PepsiCo' OR spolka = 'CocaCola').win:length(1) as curr " +
                "join KursAkcji(spolka = 'PepsiCo' OR spolka = 'CocaCola').std:firstunique(spolka) as first on curr.spolka=first.spolka";

        String zad13 = "select istream curr.data, curr.kursZamkniecia, curr.spolka, curr.kursZamkniecia-first.kursZamkniecia as roznica " +
                "from KursAkcji.win:length(1) as curr " +
                "join KursAkcji.std:firstunique(spolka) as first on curr.spolka=first.spolka " +
                "having curr.kursZamkniecia > first.kursZamkniecia";

        String zad14 = "select istream A.data, B.data, A.kursOtwarcia, B.kursOtwarcia, A.spolka " +
                "from KursAkcji.win:ext_timed(data.getTime(), 7 days) as A " +
                "join KursAkcji.win:ext_timed(data.getTime(), 7 days) as B on A.spolka = B.spolka " +
                "where B.kursOtwarcia - A.kursOtwarcia > 3";

        String zad15 = "select istream data, spolka, obrot  " +
                "from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
                "order by obrot desc limit 3";

        String zad16 = "select istream data, spolka, obrot  " +
                "from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
                "order by obrot desc limit 1 offset 2";

        EPDeployment deployment = compileAndDeploy(epRuntime, zad16);
        ProstyListener prostyListener = new ProstyListener();
        for (EPStatement statement : deployment.getStatements()) {
            statement.addListener(prostyListener);
        }

        InputStream inputStream = new InputStream();
        inputStream.generuj(epRuntime.getEventService());
    }

    public static EPDeployment compileAndDeploy(EPRuntime epRuntime, String epl) {
        EPDeploymentService deploymentService = epRuntime.getDeploymentService();
        CompilerArguments args = new CompilerArguments(epRuntime.getConfigurationDeepCopy());
        EPDeployment deployment;
        try {
            EPCompiled epCompiled = EPCompilerProvider.getCompiler().compile(epl, args);
            deployment = deploymentService.deploy(epCompiled);
        } catch (EPCompileException e) {
            throw new RuntimeException(e);
        } catch (EPDeployException e) {
            throw new RuntimeException(e);
        }
        return deployment;
    }
}