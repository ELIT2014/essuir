package ua.edu.sumdu.essuir;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import java.util.*;

@Controller
public class TotalStatisticsController {

    private static Logger log = Logger.getLogger(TotalStatisticsController.class);

    @RequestMapping(value = "/api", method = RequestMethod.GET)
    @ResponseBody
    public Map<String,Long> getTotalStatistics(HttpServletRequest request){
        Map<String,Long> stat = new HashMap<String, Long>();
        StatisticData sd;
        try {
            org.dspace.core.Context context = org.dspace.app.webui.util.UIUtil.obtainContext(request);
            sd = EssuirStatistics.getTotalStatistic(context);
            stat.put("TotalCount",sd.getTotalCount());
            stat.put("TotalViews", sd.getTotalViews());
            stat.put("TotalDownloads",sd.getTotalDownloads());
            stat.put("CurrentMonthStatisticsViews",getCurrentMonthStatisticsViews(sd));
            stat.put("CurrentMonthStatisticsDownloads",getCurrentMonthStatisticsDownloads(sd));
        }catch (Exception ex) {
            log.error(ex.getMessage(), ex);
        }
        return stat;
    }

    private long getCurrentMonthStatisticsViews(StatisticData sd){
        long totalViews = sd.getTotalViews();
        final int year2011Views = 237448;
        final int year2012Views = 750963;
        final int year2013Views = 1309485;
        final int year2014Views = 4003814;
        final int janViews = 109276;
        final int febViews = 48695;
        return totalViews - year2011Views - year2012Views - year2013Views - year2014Views - janViews - febViews;
    }

    private long getCurrentMonthStatisticsDownloads(StatisticData sd){
        long totalDownloads = sd.getTotalDownloads();
        final int year2011Downloads = 322936;
        final int year2012Downloads = 1198317;
        final int year2013Downloads = 2638394;
        final int year2014Downloads = 4641129 ;
        final int janDownloads = 189743;
        final int febDownloads = 393405;
        return totalDownloads - year2011Downloads  - year2012Downloads - year2013Downloads - year2014Downloads - janDownloads - febDownloads;
    }
}
